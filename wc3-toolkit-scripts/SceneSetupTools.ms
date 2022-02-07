macroScript SceneSetupTools category:"Warcraft III Tools" tooltip:"Scene Setup Tools" Icon:#("MergeAnim",4) (

include "RelicMaterialConverter.ms"

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

rollout rlt_QuickEditUtil "Quick Edit Util v1.0.0"(
    checkbox chk_suprr_zero_weight "Remove Zero Weights" checked:true
    checkbox chk_convert_mat "Convert Relic to Warcraft material" checked:true
    checkbox chk_scale "Scale up to mdx standard" checked:true
    spinner spin_scale "Scaling Value" range:[0,100,60] align:#center
    button btn_exec "Execute Quick Edit"

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
