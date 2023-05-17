align_mode=#(true,false,false)
 base_vertex 																				--base vert coordinates for align to one vert mode
 theshape1 																					--base vert 1 shape name
 theshape2 																					--base vert 2 shape name	
 theshape3 																					--target verts shape name
 spn1   																					-- base vert 1 spline number
 spn2  																						-- base vert 2 spline number
 spn3=#()  																					-- target verts spline number array
 tverts_type                                                         						--modifier name of target verts
 target_verts=#() 																			--target verts numbers
 
 fn dest_coordinate bv1 bv2 tv  =  															--for calculating the abstract line between two base verts
(	
	da= (bv2 - bv1)            										 
	c=dot da tv            											 
	a=(da[1]*bv1[1])+(da[2]*bv1[2])+(da[3]*bv1[3])
	b=(da[1]^2)+(da[2]^2)+(da[3]^2)
	t=(c-a)/b
	tc=[ (bv1[1]+da[1]*t) , (bv1[2]+da[2]*t) , (bv1[3]+da[3]*t) ]
	return tc
)

fn set_knot_coordinates sn vn   =															-- set new coordinates of target knots in splines
(								
	knt=getknotpoint theshape3 sn vn
	in_vec=getinvec theshape3 sn vn
	out_vec=getOutVec theshape3 sn vn
	if align_mode[1]==true then (out_vec.x = in_vec.x = knt.x = base_vertex[1])
	if align_mode[2]==true then (out_vec.y = in_vec.y = knt.y = base_vertex[2])
	if align_mode[3]==true then (out_vec.z = in_vec.z = knt.z = base_vertex[3])
	setOutVec theshape3 sn vn out_vec
	setInVec theshape3 sn vn in_vec
	setknotpoint theshape3 sn vn knt						
)

fn set_vertex_coordinates_editable_poly tv_number base_vertex =								--set new coordinates of target verts in editable poly 
(
	a=polyop.getvert theshape3 tv_number 						                            --target vert original coordinates
	if align_mode[1]==true then (a[1]=base_vertex[1]) 
	if align_mode[2]==true then (a[2]=base_vertex[2])
	if align_mode[3]==true then (a[3]=base_vertex[3])
	polyop.setvert theshape3 tv_number a
)

fn set_vertex_coordinates_edit_poly tv_number base_vertex =									--set new coordinates of target verts in edit_poly 
(
  t_type=tverts_type
	a=theshape3.modifiers[t_type].getvertex tv_number                                        --target vert original coordinates
	if align_mode[1]==true then (a[1]=base_vertex[1]) 
	if align_mode[2]==true then (a[2]=base_vertex[2])
	if align_mode[3]==true then (a[3]=base_vertex[3])
	EditPolyMod.SetVert theshape3.edit_poly #{tv_number} a node:theshape3
)

fn modifiertype=  																			--returns current modifier name in modifier stack
(	
	currentmodifier=modpanel.getcurrentobject()
    if currentmodifier==undefined then(messagebox"modify panel is not open")
	else 
    (   
        modifiername=classof currentmodifier
        return modifiername
    )   
)

fn editpoly_selected_verts=																	--return selected vert(s) index(es) as BitArray
(
	selected_verts_numbers=#()
	vertex_status=currentmod.getselection #vertex
	j=1
	for i=1 to vertex_status.count do
	(
		if vertex_status[i]==true then
		(
			selected_verts_numbers[j]=i
			j +=1
		)
	)
	return selected_verts_numbers
)	
	
rollout vertex_aligner "vertex aligner"
(
   
	local system_units_string = "system unit: " + units.systemtype as string 				--take system unit to show in coordinate align mode
	local bv1_n																				--base vertex 1 index
	local bv1																				--base vertex 1 coordinates				
	local bv2_n																				--base vertex 2 index
	local bv2																				--base vertex 2 coordinates
	local tvn																				--target vert index
	local tvc																				--target vert(s) count
	local knot_selected = #()
   
	
	
	--*******************************************************************************************************************
	--                                          align between two vertex   sets
	--*******************************************************************************************************************
	
	group  "                       "  										
	(
		label label1 "ref vert 1" align:#left enabled:true offset:[0,2]
		button set_bv1 "set"   enabled:true width:50 height:18  align:#right offset:[0,-20]
		on set_bv1 pressed do                                                                  --set ref vert1
		( 
			theshape1= $
			
			if modifiertype() ==editable_poly then
			(
				knot_selected=(polyop.getvertselection theshape1) as array
				if knot_selected.count==0 then(messagebox"no vertex selected")
				else if knot_selected.count > 1 then(messagebox"more than one vertex selected")
				else if knot_selected.count == 1 then(vertex_aligner.bv1=polyop.getvert theshape1 knot_selected[1])
				
			)
			else if modifiertype() ==SplineShape or modifiertype() == line then
			(													
				nothing_selected=0
				for i in 1 to  numsplines theshape1 do 
				(
					
					knot_selected=getknotselection theshape1 i
					if knot_selected.count == 1 then
					(
						spn1=i
						vertex_aligner.bv1=getKnotPoint theshape1 spn1 knot_selected[1]
						
					)
					else if knot_selected.count > 1 then (messagebox "more than one vertex selected")
					else (nothing_selected +=  1 )
				)
				
				if nothing_selected == numsplines theshape1 then(messagebox"no vertex selected")	
			)
			else if modifiertype() ==edit_poly then
			(
			   knot_selected=editpoly_selected_verts()
                if vertex_aligner.knot_selected.count ==1 then
                (
                    
                    vertex_aligner.bv1=$.modifiers[modifiertype()].getVertex vertex_aligner.knot_selected[1]
  
                )				
                else if knot_selected.count == 0 then (messagebox"no vertex selected")
                else if knot_selected.count >= 2 then (messagebox"more than one vertex selected")	
				
				
				
				
			)
			
		)
		
		label label2 "ref vert 2"	align:#left	 enabled:true	offset:[0,2]                   --set ref vert2
		button set_bv2 "set" iconName:@"PolyTools\TransformTools\PB_CW"  enabled:true width:50 height:18 align:#right offset:[0,-22]
		on set_bv2 pressed do
		( 
			theshape2= $
			
			if modifiertype() ==editable_poly then
			(
				knot_selected=(polyop.getvertselection theshape1) as array
				if knot_selected.count==0 then(messagebox"no vertex selected")
				else if knot_selected.count > 1 then(messagebox"more than one vertex selected")
				else if knot_selected.count == 1 then(vertex_aligner.bv2=polyop.getvert theshape2 knot_selected[1])
				
			)
			else if modifiertype() ==SplineShape or modifiertype() == line then
			(													
				nothing_selected=0
				for i in 1 to  numsplines theshape2 do 
				(
					
					knot_selected=getknotselection theshape2 i
					if knot_selected.count == 1 then
					(
						spn2=i
						vertex_aligner.bv1=getKnotPoint theshape2 spn2 knot_selected[1]
						
					)
					else if knot_selected.count > 1 then (messagebox "more than one vertex selected")
					else (nothing_selected +=  1 )
				)
				
				if nothing_selected == numsplines theshape2 then(messagebox"no vertex selected")	
			)
			else if modifiertype() ==edit_poly then
			(
			    knot_selected=editpoly_selected_verts()
                if knot_selected.count ==1 then
                (
                    
                    bv2=$.modifiers[modifiertype()].getVertex knot_selected[1]
  
                )				
                else if knot_selected.count == 0 then (messagebox"no vertex selected")
                else if knot_selected.count >= 2 then (messagebox"more than one vertex selected")	
				
			)
			
		)
		
		label label3 "target vert(s)" align:#left enabled:true offset:[0,2]                     --set target vert(s)
		button set_tvn "set" iconName:@"PolyTools\TransformTools\PB_CW"  enabled:true width:50 height:18 align:#right offset:[0,-22]
		on set_tvn pressed do
        ( 	
            
            theshape3= $
            if modifiertype() ==editable_poly then
            (
                tverts_type= modifiertype()
                knot_selected=(polyop.getvertselection theshape3) as array
                if knot_selected.count!=0 then (target_verts = knot_selected ; vertex_aligner.tvc=target_verts.count)
                else(messagebox"no vertex selected")
                
            )
            else if modifiertype() ==SplineShape or modifiertype() == line then
            (
                tverts_type= modifiertype()
                nothing_selected = 0
                for i in 1 to  numsplines theshape3 do 
                (
                    knot_selected=getknotselection theshape3 i
                    if knot_selected.count != 0 then
                    (
                        spn3[i]=knot_selected
                    )
                    else if knot_selected.count == 0 then(nothing_selected += 1)
                )
                if nothing_selected== numsplines theshape3 then (messagebox"no vertex selected")
            )	
            else if modifiertype() ==edit_poly then
            (
                tverts_type= modifiertype()
                vertex_aligner.knot_selected=editpoly_selected_verts()
                if vertex_aligner.knot_selected.count >= 1 then
                (
                    
                    target_verts=vertex_aligner.knot_selected

                )				
                else if vertex_aligner.knot_selected.count == 0 then (messagebox"no vertex selected")
                    
            )

        )				
				
	)
   
	--*******************************************************************************************************************
	--                                           align to one vertex   sets
	--*******************************************************************************************************************
	
	
	group "                                    " 
	(
		label set_bvert "base vertex " enabled:false align: #left offset:[0,0]
		button s_b_vertex "set"  width:50 height:18 enabled:false align: #right offset:[0,-20]
		on s_b_vertex pressed do                                                            --set base vertex
		( 
			theshape1= $
			if modifiertype() ==editable_poly then
			(
				knot_selected=(polyop.getvertselection theshape1) as array
				if knot_selected.count == 1 then(base_vertex=polyop.getvert theshape1 knot_selected[1])
				else if knot_selected.count==0 then(messagebox"no vertex selected")
				else if knot_selected.count > 1 then(messagebox"more than one vertex selected")
					
			)
			if modifiertype() ==SplineShape or modifiertype() == line then
			(
				nothing_selected=0
				for i in 1 to  numsplines theshape1 do 
				(
					
					knot_selected=getknotselection theshape1 i
					if knot_selected.count == 1 then
					(
						spn1=i
						base_vertex=getKnotPoint theshape1 spn1 knot_selected[1]
						
					)
					else if knot_selected.count > 1 then (messagebox "more than one vertex selected")
					else (nothing_selected +=  1 )
				)
				
				if nothing_selected == numsplines theshape1 then(messagebox"no vertex selected")	
			)
			if modifiertype() == edit_poly then
			(
				knot_selected=editpoly_selected_verts()
				if vertex_aligner.knot_selected.count ==1 then
                (
                    
                    base_vertex=$.modifiers[modifiertype()].getVertex vertex_aligner.knot_selected[1]
  
                )				
                else if knot_selected.count == 0 then (messagebox"no vertex selected")
                else if knot_selected.count >= 2 then (messagebox"more than one vertex selected")
			)
		)	
			
		label label4 "target vert(s)" enabled:false align:#left offset:[0,-4] 
		button target_vertices_array_maker "set"  width:50 height:18 align:#right offset:[0,-18] enabled:false
		on target_vertices_array_maker pressed do                                           --set target vert(s)
		( 
				
			theshape3= $
			if modifiertype() ==editable_poly then
			(
				knot_selected=(polyop.getvertselection theshape3) as array
				if knot_selected.count==0 then(messagebox"no vertex selected")
				else (target_verts = knot_selected ; vertex_aligner.tvc=target_verts.count)
			)
			if modifiertype() ==SplineShape or modifiertype() == line then 
			(
				nothing_selected=0
				for i in 1 to  numsplines theshape3 do 
				(
					knot_selected=getknotselection theshape3 i
					if knot_selected.count != 0 then
					(
						spn3[i]=knot_selected
					)
					else if knot_selected.count == 0 then(nothing_selected += 1)
				)	
				if nothing_selected == numsplines theshape3 then (messagebox"no vertex selected")
			)
			if modifiertype() == edit_poly then
			(
				tverts_type= modifiertype()
			vertex_aligner.knot_selected=editpoly_selected_verts()
			if vertex_aligner.knot_selected.count >= 1 then
			(
				
				target_verts=vertex_aligner.knot_selected

			)				
			else if vertex_aligner.knot_selected.count == 0 then (messagebox"no vertex selected")
				)
		)
	)
	
	--*******************************************************************************************************************
	--                                         align to coordinates   sets
	--*******************************************************************************************************************
	
	group "                       " 
	(
		label system_unit enabled:false
		on vertex_aligner open do (system_unit.caption =system_units_string)
		
		spinner x_coordinate  type: #float range:[-256000000,256000000,0] scale:0.001 enabled: false fieldwidth:40  offset:[0,0]  align: #right
		label spinner_x "target  X :" enabled:false align: #left offset:[0,-20]
		
		spinner y_coordinate  type: #float range:[-256000000,256000000,0] scale:0.001 enabled: false fieldwidth:40 offset:[0,0]  align: #right
		label spinner_y "target  Y :" enabled:false align: #left offset:[0,-20]
		
		
		spinner z_coordinate  type: #float range:[-256000000,256000000,0] scale:0.001 enabled: false fieldwidth:40 offset:[0,0] align: #right
		label spinner_z "target  Z :" enabled:false align: #left offset:[0,-20]
		
		button t_verts "set" iconName:@"PolyTools\TransformTools\PB_CW" width:50 height:18	offset:[0,0] align:#right enabled: false
		label t_vertss "target vert(s)" enabled:false align: #left offset:[0,-21]
		on t_verts pressed do                                                           --set target vert(s)
			(
				theshape3= $
				if modifiertype() ==editable_poly then
				(
					knot_selected=(polyop.getvertselection theshape3) as array
					if knot_selected.count==0 then(messagebox"no vertex selected")
					else (target_verts = knot_selected ; vertex_aligner.tvc=target_verts.count)
				)
				if modifiertype() ==SplineShape or modifiertype() == line then 
				(
					nothing_selected=0
					for i in 1 to  numsplines theshape3 do 
					(
						knot_selected=getknotselection theshape3 i
						if knot_selected.count != 0 then
						(
							spn3[i]=knot_selected
						)
						else if knot_selected.count == 0 then(nothing_selected += 1)
					)	
					if nothing_selected == numsplines theshape3 then (messagebox"no vertex selected")
				)
				if modifiertype() == edit_poly then
				(
					tverts_type= modifiertype()
					vertex_aligner.knot_selected=editpoly_selected_verts()
						
					if vertex_aligner.knot_selected.count >= 1 then
					(
						
						target_verts=vertex_aligner.knot_selected
					)				
					else if vertex_aligner.knot_selected.count == 0 then (messagebox"no vertex selected")
				)
			)
		
		
		
	)
		
    --*******************************************************************************************************************
    --                                          UI groups and sections enable/disable
    --*******************************************************************************************************************		
	radiobuttons aligner_mode     labels:#("align between two vertex","align to one vertex","align to coordinates")	align:#left offsets:#([-10,-273],[-10,-200],[-10,-150])
		
	on aligner_mode changed state do 
	(
		if aligner_mode.state==3 then
		(
			vertex_aligner.t_vertss.enabled=true
			vertex_aligner.t_verts.enabled=true
			if vertex_aligner.align_type_x.checked==true then(vertex_aligner.x_coordinate.enabled=true)
			if vertex_aligner.align_type_y.checked==true then(vertex_aligner.y_coordinate.enabled=true) 
			if vertex_aligner.align_type_z.checked==true then(vertex_aligner.z_coordinate.enabled=true)
			vertex_aligner.spinner_x.enabled=true
			vertex_aligner.spinner_y.enabled=true
			vertex_aligner.spinner_z.enabled=true
			vertex_aligner.label4.enabled=false
			vertex_aligner.set_bvert.enabled=false
			vertex_aligner.align_type_x.enabled=true 
			vertex_aligner.align_type_y.enabled=true 
			vertex_aligner.align_type_z.enabled=true 
			system_unit.enabled=true
			vertex_aligner.target_vertices_array_maker.enabled= false
			s_b_vertex.enabled= false
			label1.enabled=false
			label2.enabled=false
			label3.enabled=false
			set_bv1.enabled=false
			set_bv2.enabled=false
			set_tvn.enabled=false
		)
		else if aligner_mode.state== 1 then
		(
			vertex_aligner.t_vertss.enabled=false
			vertex_aligner.t_verts.enabled=false
			vertex_aligner.spinner_x.enabled=false
			vertex_aligner.spinner_y.enabled=false
			vertex_aligner.spinner_z.enabled=false
			vertex_aligner.label4.enabled=false
			vertex_aligner.set_bvert.enabled=false
			vertex_aligner.align_type_x.enabled=false 
			vertex_aligner.align_type_y.enabled=false 
			vertex_aligner.align_type_z.enabled=false 
			vertex_aligner.target_vertices_array_maker.enabled=false 
			s_b_vertex.enabled= false
			x_coordinate.enabled=false 
			y_coordinate.enabled=false
			z_coordinate.enabled=false
			system_unit.enabled=false
			label1.enabled=true
			label2.enabled=true
			label3.enabled=true
			set_bv1.enabled=true
			set_bv2.enabled=true
			set_tvn.enabled=true
			
		)
		else if aligner_mode.state==2 then
		(
			vertex_aligner.t_vertss.enabled=false
			vertex_aligner.t_verts.enabled=false
			vertex_aligner.spinner_x.enabled=false
			vertex_aligner.spinner_y.enabled=false
			vertex_aligner.spinner_z.enabled=false
			vertex_aligner.label4.enabled=true
			vertex_aligner.set_bvert.enabled=true
			vertex_aligner.align_type_x.enabled= true
			vertex_aligner.align_type_y.enabled= true
			vertex_aligner.align_type_z.enabled= true
			vertex_aligner.target_vertices_array_maker.enabled= true
			s_b_vertex.enabled= true
			x_coordinate.enabled=false 
			y_coordinate.enabled=false
			z_coordinate.enabled=false
			system_unit.enabled=false
			label1.enabled=false
			label2.enabled=false
			label3.enabled=false
			set_bv1.enabled=false
			set_bv2.enabled=false
			set_tvn.enabled=false
		)
	)
	

    --*******************************************************************************************************************
    --                                          X axis align  ENABLE/DISABLE
    --*******************************************************************************************************************	
	checkbutton  align_type_x "X" checked:true   enabled: false  align: #left width:35 height:20 offset:[0,0]
	on align_type_x changed state do
	( 	
		if state == on 
			then align_mode[1]=true
			else align_mode[1]=false
		if state== on and vertex_aligner.aligner_mode.state==3
			then x_coordinate.enabled= true 
			else x_coordinate.enabled= false
	)
			
	
    --*******************************************************************************************************************
    --                                         Y axis align  ENABLE/DISABLE
    --*******************************************************************************************************************	
	checkbutton  align_type_y "Y" checked:false   enabled:false align: #center offset:[0,-26] width:35 height:20
	on align_type_y changed state do
	(	
		if state == on 
			then (align_mode[2]=true)
			else (align_mode[2]=false)
		if state== on and vertex_aligner.aligner_mode.state==3 
			then (y_coordinate.enabled= true )
			else (y_coordinate.enabled= false)
	)
	
    --*******************************************************************************************************************
    --                                         Z axis align  ENABLE/DISABLE
    --*******************************************************************************************************************
	checkbutton  align_type_z "Z" checked:false  enabled:false align: #right offset:[0,-26] width:35 height:20
	on align_type_z changed state do
	(	
		if state == on 
			then align_mode[3]=true
			else align_mode[3]=false
		if state== on and vertex_aligner.aligner_mode.state==3
			then z_coordinate.enabled= true 
			else z_coordinate.enabled= false
	)
	
	
    --*******************************************************************************************************************
    --                                             "align" button press
    --*******************************************************************************************************************	
	button run "align" iconName:@"PolyTools\TransformTools\PB_CW" width:140 height:35 offset:[0,5]
	on run pressed do 
	(  
		--*******************************************************************************************************************
		--                                     align between two vertex  
		--*******************************************************************************************************************
		if aligner_mode.state ==1 then
        (
            if tverts_type == Editable_Poly  then
            (
                for i in 1 to target_verts.count do
				(
						tv_number=target_verts[i]
						tv=polyop.getVert theshape3 tv_number
						tc=dest_coordinate vertex_aligner.bv1 vertex_aligner.bv2 tv
						undo on (polyop.setVert theshape3 tv_number tc)
					   
				)
			)
            else if tverts_type == edit_poly then
            (
                for i in 1 to target_verts.count do
                (
					
                    tv_number=target_verts[i]
					tv=theshape3.modifiers[modifiertype()].getvertex tv_number
                    tc=dest_coordinate vertex_aligner.bv1 vertex_aligner.bv2 tv
                    undo on 
					(
						editpolymod.setVert theshape3.edit_poly #{tv_number} tc
						theshape3.modifiers[#Edit_Poly].Commit()
						
					)
                )
            )
            else if (tverts_type == line or tverts_type == SplineShape) then
            (
                for j in 1 to spn3.count do 
                (
                    if spn3[j].count != 0 then
                    (
                        sn=j
                        tvn=spn3[j]
                        
                        for i in 1 to spn3[j].count do
                        (
                            bv1=vertex_aligner.bv1
                            bv2=vertex_aligner.bv2
                            tv=getknotpoint theshape3 sn tvn[i]
                            tc = dest_coordinate bv1 bv2 tv											
                            vn=tvn[i]
                            undo on
							(
								setOutVec theshape3 sn vn tc
								setInVec theshape3 sn vn tc
								setknotpoint theshape3 sn vn tc
							)
                        )
                    )	
                )	
            )
		)
		--*******************************************************************************************************************
		--                        "align to one vertex" and "align to coordinates"
		--*******************************************************************************************************************
		else if( aligner_mode.state==2 or aligner_mode.state ==3) then
		(	
			if aligner_mode.state==3 then   												--align to coordinates mode
			( 	base_vertex[1]=vertex_aligner.x_coordinate.value
				base_vertex[2]=vertex_aligner.y_coordinate.value
				base_vertex[3]=vertex_aligner.z_coordinate.value
			)
			
			if tverts_type == Editable_Poly then
			(
				
				
				for i in 1 to vertex_aligner.tvc do
				(	
					
					tv_number=target_verts[i]
					undo on (set_vertex_coordinates_editable_poly tv_number base_vertex)
					
				)
				
			)
			else if tverts_type == edit_poly then
			(
				for i in 1 to target_verts.count do
				(
					tv_number=target_verts[i]
					undo on 
					(
						set_vertex_coordinates_edit_poly tv_number base_vertex
						theshape3.modifiers[#Edit_Poly].Commit()
					)
				)
			)
			else if (tverts_type == line or tverts_type == SplineShape)  then
			(	
				
				for j in 1 to spn3.count do 
				(
					if spn3[j].count != 0 then
					(
						sn=j --spline number
						tvn=spn3[j] --target vertices array
						for i in 1 to spn3[j].count do
						(
							sn=j
							vn=tvn[i]
							undo on (set_knot_coordinates sn vn) 
							
						)
					
					)	
				)
				
			)					
		)	
		
		if (tverts_type == line or tverts_type == SplineShape) then (updateShape theshape3)
		else if (tverts_type == edit_poly) then (update theshape3)
	)	
	
	
	
hyperlink donation "DONATION" address:"https://commerce.coinbase.com/checkout/9bb3a928-7cf1-492c-b162-3b59d08515ee" align:#center
	

)
createDialog vertex_aligner 155 370
