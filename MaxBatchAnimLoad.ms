macroScript BatchLoad category:"AnimationScript" tooltip:"Max Batch Anim Load" Icon:#("MergeAnim",4) (

function getSequenceName filename = (
    local sequenceName = "Not Named"
    local animKeyWords = filterstring filename "_."
    local commonWord = #("attack", "stand", "sprint", "run", "die", "weaponskill")

    for j = 1 to commonWord.count do (
        local idx = findItem animKeyWords commonWord[j]
        if idx != 0 then (
            sequenceName = animKeyWords[idx]
            if animKeyWords[animKeyWords.count - 1][1] == "0" then (
                sequenceName = sequenceName + " - " + animKeyWords[animKeyWords.count - 1][2]
            sequenceName[1] = toUpper sequenceName[1]
            )
        j = commonWord.count
        )
        else (
            sequenceName = substituteString filename ".xaf" ""
        )
    )
    return sequenceName
)

function setAnimKey noteTrack sequenceName startTime endTime = (
    local key1 = addNewNoteKey noteTrack.keys startTime
    local key2 = addNewNoteKey noteTrack.keys endTime
    key1.value = sequenceName
    key2.value = sequenceName
)

function getMaxFiles dir = (
	local theFiles = #()

	local tempFiles = getFiles (dir + "/*.xaf")
	if tempFiles.count > 0 then (
		join theFiles tempFiles
	)
	theFiles
)

rollout rlt_MaxBatchAnimeLoad "Batch Anime Load v0.4.1"(
	button btn_directory "Browse" width:175
	multilistbox lst_files "Files: " height:15 offset:[-2,0]
	button btn_none "None" align:#left width:35 height:16
	button btn_all "All" offset:[0,-21] align:#right width:35 height:16
	button btn_load "Load" offset:[0,-22] width:75
	progressBar pgb_loadProgress

	on btn_directory pressed do (
		if (dir = getSavePath initialDir:(getDir #animations) caption:"Select the directory you want to load files from") != undefined then (
			btn_directory.text = dir
			bm_files = getMaxFiles dir

			lst_files.items = for f in bm_files collect (filenameFromPath f)
		)
	)

	on btn_none pressed do ( lst_files.selection = #{} )

	on btn_all pressed do (
		lst_files.selection = #{1..(lst_files.items.count)}
	)

	on btn_load pressed do (
		local toLoad = #()
		local sel = (lst_files.selection as array)

		actionMan.executeAction 0 "40021"  -- Selection: Select all object in scene
		max hide object toggle -- Hide geometry because we only need to load animation on the bone objects?

		local loadNbr = 0

        -- Reset note track
        while( numNoteTracks rootNode != 0 ) do deleteNoteTrack rootNode (getNoteTrack rootNode 1)

        -- Init new note track
        local NT = notetrack "animations"
        --local ftm_cnt = FrameTagManager.CreateNewTag
        --local ftm_gti = FrameTagManager.GetTagID
    	addNoteTrack rootNode NT

        local sequenceName = getSequenceName maxFileName
        setAnimKey NT sequenceName animationRange.start animationRange.end

		for i = 1 to sel.count do (

            local filename = lst_files.items[sel[i]]
            -- Construct file path
            local filepath = btn_directory.text + "\\" + filename

			LoadSaveAnimation.setUpAnimsForLoad (selection as array)
			local newStartTime = animationRange.end + 30f
            local userAttr = #()
            local userValue = #()
            if (LoadSaveAnimation.getUserAttributes filepath &userAttr &userValue) == false then (
                throw("Error, could not load animation attribute")
            )
            if (LoadSaveAnimation.loadAnimation filepath  (selection as array) insert:true insertTime:newStartTime) == false then (
				throw("Error, could not load animation " + filepath)
            )
            --currentTimeRange = gettimerange ((getNodeByName "skeleton_root").children[1].pos.controller[1].controller)
            newEndTime = newStartTime + (userValue[1] as float)
            animationRange = interval 0f newEndTime


            sequenceName = getSequenceName filename
            setAnimKey NT sequenceName newStartTime newEndTime
            --local tag1 = ftm_cnt (sequenceName + " Start") newStartTime
            --local id = ftm_gti tag1
            --local tag2 = ftm_cnt (sequenceName + " End") newEndTime lockID:id

            loadNbr += 1

			-- Update ProgressBar
			pgb_loadProgress.value = 100.*i/sel.count
		)

		-- Load complete
		local msg = loadNbr as string + " animations have been loaded"
		print msg
		messagebox msg title:"Batch Load completed"
        max hide object toggle

       -- removeZeroWeight ()
	)
)
createDialog rlt_MaxBatchAnimeLoad 210 377
)
