macroScript BatchSave category:"AnimationScript" tooltip:"Max Batch Anim Save" Icon:#("MergeAnim",4) (

global MaxFileTypeExtensions = #("max")

function getMaxFiles dir = (
	local theFiles = #()

	for f in MaxFileTypeExtensions do (
		local tempFiles = getFiles (dir + "/*." + f)
		if tempFiles.count > 0 then (
			join theFiles tempFiles
		)
	)
	theFiles
)

rollout rlt_MaxBatchAnimeSave "Batch Anime Save v1.0.0"(
	button btn_directory "Browse" width:175
	multilistbox lst_files "Files: " height:15 offset:[-2,0]
	button btn_none "None" align:#left width:35 height:16
	button btn_all "All" offset:[0,-21] align:#right width:35 height:16
	button btn_save "Save" offset:[0,-22] width:75
    checkbox chk_rename_bone "Rename duplicated bone" checked:true
    toolTip:"If 2 bones got identical name, rename the second one by appending an unique ID to it"
	progressBar pgb_saveProgress

	on btn_directory pressed do (
		if (dir = getSavePath initialDir:(getDir #animations) caption:"Select the directory you want to save files from") != undefined then (
			btn_directory.text = dir
			bm_files = getMaxFiles dir

			lst_files.items = for f in bm_files collect (filenameFromPath f)
		)
	)

	on btn_none pressed do ( lst_files.selection = #{} )

	on btn_all pressed do (
		lst_files.selection = #{1..(lst_files.items.count)}
	)

	on btn_save pressed do (
		local toSave = #()
		local sel = (lst_files.selection as array)

		for i = 1 to sel.count do append toSave (btn_directory.text + "\\" + lst_files.items[sel[i]])

		local saveNbr = 0
		for i = 1 to sel.count do (
			if ((loadMaxFile toSave[i] quiet:true)  == false) then (
				print toSave[i]
				print "fail"
			)
			newFileName = (substring toSave[i] 1 (toSave[i].count - 4)) + ".xaf"

			clearSelection()
			actionMan.executeAction 0 "40021"  -- Selection: Select All
			max hide object toggle
			BoneNodes = selection as array

            if chk_rename_bone.checked then (
                boneNames = #()
                for i = 1 to BoneNodes.count do (
                    if (appendIfUnique boneNames BoneNodes[i].name) == false then (
                        local bn = BoneNodes[i].name
                        BoneNodes[i].name = uniquename bn
                        print ("Renamed " + BoneNodes[i].name + " to " + BoneNodes[i].name)
                    )
                )
            )

			--LoadSaveAnimation.setUpAnimsForSave nodeArray keyable:true
            userAttr = #("end")
            userValue = #(animationRange.end as string)

			if (LoadSaveAnimation.saveAnimation newFileName BoneNodes userAttr userValue) == false then (
				local msg = "Error, could not save animation " + newFileName
				print msg
				messagebox msg title:"Animation Save Error"
			)
			else
				saveNbr = saveNbr + 1

			-- Update ProgressBar
			pgb_saveProgress.value = 100.*i/toSave.count
		)

		-- Save complete
		local msg = saveNbr as string + " animations have been saved"
		print msg
		messagebox msg title:"Batch Save completed"
	)
)
createDialog rlt_MaxBatchAnimeSave 210 377
)
