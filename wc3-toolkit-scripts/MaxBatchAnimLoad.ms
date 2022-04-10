macroScript BatchLoad category:"AnimationScript" tooltip:"Max Batch Anim Load" Icon:#("MergeAnim",4) (

-- Try to guess the sequence name using the filename
function getSequenceName filename = (
    local sequenceName = "unnamed"
    local animKeyWords = filterstring (getFileNameFile(filename)) "_."
    local commonWord = #("attack", "stand", "sprint", "run", "die", "weaponskill")

    for j = 1 to commonWord.count while sequenceName == "unnamed" do (
        local idx = findItem animKeyWords commonWord[j]
        if idx != 0 then (
            sequenceName = animKeyWords[idx]

            -- A animation type can have multiple file, e.g :
            -- melee_attack_01.xaf, melee_attack_02.xaf
            -- we can cast the "01" string as an integer to get the animation
            -- number and use it in the sequence name
            -- result : melee_attack_01 -> Attack - 1
            local keyWordCount = animKeyWords[animKeyWords.count] as integer
            if keyWordCount != undefined then (
                sequenceName = sequenceName + " - " + keyWordCount as string
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

function renameBone BoneNodes = (
    boneNames = #()
    for i = 1 to BoneNodes.count do (
        if (appendIfUnique boneNames BoneNodes[i].name) == false then (
            local bn = BoneNodes[i].name
            BoneNodes[i].name = uniquename bn
            print ("Renamed " + BoneNodes[i].name + " to " + BoneNodes[i].name)
        )
    )
)

rollout rlt_MaxBatchAnimeLoad "Batch Anime Load v1.0.4"(
	button btn_directory "Browse" width:175
	multilistbox lst_files "Files: " height:15 offset:[-2,0]
	button btn_none "None" align:#left width:35 height:16
	button btn_all "All" offset:[0,-21] align:#right width:35 height:16
	button btn_load "Load" offset:[0,-22] width:75
    radiobuttons radio_relative  labels:#("Relative", "Absolute") default:1
    spinner insert_at "Insert At Frame" range:[0,10000,10] align:#center type:#integer
    spinner time_interval "Time between anim" range:[0,100,30] align:#center type:#integer
	progressBar pgb_loadProgress

	on btn_directory pressed do (
		if (dir = getSavePath initialDir:(getDir #animations) caption:"Select the directory you want to load max files from") != undefined then (
			btn_directory.text = dir
			bm_files = getMaxFiles dir

			lst_files.items = for f in bm_files collect (filenameFromPath f)
		)
	)

    -- Clear files selection
	on btn_none pressed do ( lst_files.selection = #{} )

    -- Select all files
	on btn_all pressed do (
		lst_files.selection = #{1..(lst_files.items.count)}
	)

	on btn_load pressed do (
		local toLoad = #()
		local sel = (lst_files.selection as array)


		local loadCount = 0

        -- Reset note track
        while( numNoteTracks rootNode != 0 ) do deleteNoteTrack rootNode (getNoteTrack rootNode 1)

        -- Init new note track
        local NT = notetrack "animations"
    	addNoteTrack rootNode NT

        local relative
        if (radio_relative.state == 1) then (
            relative = true
        ) else (
            relative = false
        )

        try (
            for i = 1 to sel.count do (

                local filename = lst_files.items[sel[i]]
                -- Construct file path
                local filepath = btn_directory.text + "\\" + filename


                actionMan.executeAction 0 "40021"  -- Selection: Select all object in scene
                max hide object toggle -- Hide geometry because we only need to load animation on the bone objects?
                BoneNodes = selection as array
                renameBone BoneNodes

                LoadSaveAnimation.setUpAnimsForLoad BoneNodes
                local newStartTime = animationRange.end + (time_interval.value as float)
                local userAttr = #()
                local userValue = #()

                -- Edge case for keeping T pose animation
                if (insert_at.value > 0 and i == 1) then(
                    newStartTime = insert_at.value as float
                )

                -- Load the animation
                if (LoadSaveAnimation.getUserAttributes filepath &userAttr &userValue) == false then (
                    throw("Error, could not load animation attribute")
                )
                print filepath
                print BoneNodes
                print "debug 1 " + (newStartTime as string)
                if (LoadSaveAnimation.loadAnimation filepath  BoneNodes relative:relative insert:true insertTime:newStartTime) == false then (
                    throw("Error, could not load animation " + filepath)
                )

                print "debug 2"
            -- TODO: Check if userValue is undefined
                newEndTime = newStartTime + (userValue[1] as float)

                print "debug 3"
            -- Update animation range
                animationRange = interval 0f newEndTime

                -- Set notetrack name
                sequenceName = getSequenceName filename
                setAnimKey NT sequenceName newStartTime newEndTime

                loadCount += 1

                -- Update ProgressBar
                pgb_loadProgress.value = 100.*i/sel.count
            )
        ) catch (
            local e = getCurrentException()
            messagebox e title:"Error encountered while loading animation"
        )

		-- Load complete
		local msg = loadCount as string + " animations have been loaded"
		print msg
		messagebox msg title:"Batch Load completed"
        max hide object toggle

	)
)
createDialog rlt_MaxBatchAnimeLoad 210 377
)
