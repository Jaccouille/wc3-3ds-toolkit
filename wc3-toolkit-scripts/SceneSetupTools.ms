macroScript SceneSetupTools category:"Warcraft III Tools" tooltip:"Scene Setup Tools" Icon:#("MergeAnim",4) (

include "RelicMaterialConverter.ms"
struct Sequence (
	name,
	startTime,
	endTime
)

--Utility function from Neodex Plugin
fn ArrayMap array &func =
(
    local result = #()
    if array.count != 0 then result[array.count] = undefined
    local i = 1
    for elem in array do
    (
        result[i] = (func elem)
        i += 1
    )
    result
)

--Utility function from Neodex Plugin
fn GetSequenceData =
(
    local result = #()
    if HasNoteTracks Rootnode then
    (
        local Nt = GetNoteTrack Rootnode 1
        local keys = Nt.keys
        for k in keys do
        (
            local notFound = true
            for i = 1 to result.count where notFound do
            (
                if result[i][1].value == k.value then
                (
                    append result[i] k
                    notFound = false
                )
            )
            if notFound then
                append result #(k)
        )
    )
    for i = result.count to 1 by -1 where result[i].count != 2 do deleteItem result i
    result
)

--Utility function from Neodex Plugin
fn setSequenceData key1 key2 =
(
    local data = filterString key1.value "\"\n\t\x0D"
    local animName = data[1]
    Sequence animName key1.time key2.time
)

fn LoadSequences =
(
    ArrayMap (GetSequenceData ()) (fn tmp a = setSequenceData a[1] a[2])
)

function removeZeroWeight = (
    -- Select modifier panel
    max modify mode
    for obj in objects where classOf obj == Editable_mesh do (
        -- Select mesh
        select obj

        -- Need to open weight table for each mesh in order to remove zero weight
        skinOps.buttonWeightTable obj.modifiers[#skin]
        skinOps.removeZeroWeights obj.modifiers[#skin]
        skinOps.closeWeightTable obj.modifiers[#skin]
    )
)

function setAnimKey noteTrack sequenceName startTime endTime = (
    local key1 = addNewNoteKey noteTrack.keys startTime
    local key2 = addNewNoteKey noteTrack.keys endTime
    key1.value = sequenceName
    key2.value = sequenceName
)

function parseSequenceData sequenceDataStr =
(
    local data = filterString sequenceDataStr ";"
    data[1] = substituteString data[1] "Name:" ""
    data[2] = substituteString data[2] " start:" ""
    data[3] = substituteString data[3] " end:" ""
    local formatted_data = #()
    append formatted_data data
    data
)

rollout rlt_QuickEditUtil "Quick Edit Util v1.0.1"(
    checkbox chk_suprr_zero_weight "Remove Zero Weights" checked:true
    checkbox chk_convert_mat "Convert Relic to Warcraft material" checked:true
    checkbox chk_scale "Scale up to mdx standard" checked:true
    spinner spin_scale "Scaling Value" range:[0,100,60] align:#center
    button btn_save_seq "Save Sequences Names"
    toolTip:"Save current note track keys name with their position in a txt file"
    button btn_load_seq "Load Sequences Names"
    toolTip:"WARNING: This action will replace current scene note track keys by the one loaded from the selected file"
    button btn_exec "Execute Quick Edit"

    on btn_save_seq pressed do (
        filename = getSaveFileName types:"TXT File (*.txt)|*.txt"
        if filename != undefined then (
            output_file = createfile filename
            local sequences = LoadSequences()
            for s in sequences do
            (
                format "Name:%; start:%; end:%\n" s.name s.starttime s.endtime  to:output_file
            )
            close output_file
            local msg = sequences.count as string + " animations have been saved in " + filename
            print msg
            messagebox msg title:"Sequence names save success"
        )
    )

    on btn_load_seq pressed do (
        filename = getOpenFileName types:"TXT File (*.txt)|*.txt"
        if filename != undefined then (
            sequences = #()
            input_file = openfile filename
            while not (eof input_file) do (
            append sequences (parseSequenceData (readLine input_file))
            )

            -- Reset note track
            while( numNoteTracks rootNode != 0 ) do deleteNoteTrack rootNode (getNoteTrack rootNode 1)
            -- Init new note track
            local NT = notetrack "animations"
            addNoteTrack rootNode NT

            for i = 1 to sequences.count do (
                sequenceName = sequences[i][1]
                newStartTime = sequences[i][2] as float
                newEndTime = sequences[i][3] as float

                -- Update animation range
                animationRange = interval 0f newEndTime

                -- Set notetrack name
                setAnimKey NT sequenceName newStartTime newEndTime
            )
            close input_file
            local msg = sequences.count as string + " animations have been load from " + filename
            print msg
            messagebox msg title:"Sequence names load success"
        )
    )

    on btn_exec pressed do (
        if chk_suprr_zero_weight.checked then
            removeZeroWeight ()
        if chk_scale.checked then
            rescaleWorldUnits spin_scale.value
        if chk_convert_mat.checked then
            RelicToWarcraftMaterial ()

    )
)
createDialog rlt_QuickEditUtil 210 377
)
