module EquipmentHelper
    def formatSize(sizes)

        sizes = sizes.split(",")
        return "高さ：#{sizes[0]}cm 幅：#{sizes[1]}cm 奥行き：#{sizes[2]}cm"

    end
    def formatArray(text,index)

        array = text.split(",")
        return array[index]

    end
    def shelf(id)

        shelf = Shelf.find(id)
        return shelf

    end
end
