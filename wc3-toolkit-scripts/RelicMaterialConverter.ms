--Simple script to convert Relic Material to Warcraft 3 One

function RelicToWarcraftMaterial =
(
    local new_mat_nbr = 0

    -- Relic Materials are contained in a MultiMaterial
    local Editable_meshes = for item in objects where \
    (isKindOf item.material MultiMaterial) collect item

	-- Get multi material
	local multiMat = getMeditMaterial 1

    print("Iterating over material")
    -- Creating WC3 Materials
    for i = 1 to multiMat.count do (
        local subMaterial = multiMat.materialList[i]

        if (classOf subMaterial == RelicMaterial) then
        (
            local wc3Material = Warcraft3 ()

            print("Created " + subMaterial.name + " wc3 mat")
            wc3Material.name = subMaterial.name
            wc3Material.texture = subMaterial.diffuseTex
            meditmaterials[i + 1] = wc3Material
            new_mat_nbr += 1
        )
    )

    -- Assigning Meshes to WC3 Materials
	if (isKindOf multiMat MultiMaterial) then
	(
		for mesh in Editable_meshes do
		(
			local relicMatName = (filterString mesh.name "[,]")
            for mat in meditmaterials where \
                (classOf mat == Warcraft3 and findItem relicMatName mat.name != 0) do (
                mesh.material = mat
                mat.showInViewPort = true
				)
		)
    )
    else
        print "No Relic materials found"
	print  (append (new_mat_nbr as string)  " Warcraft 3 Material created")
)
