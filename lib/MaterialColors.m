classdef MaterialColors
    % MATERIALCOLORS The entire Material color palette.
    %
    % Access the colors and variant via the color names as properties.
    % E.g.: MaterialColors.red(50), MaterialColors.lightBlue(500).
    %
    % Returns a Color object.
    properties(Constant, Access=private)
        cRed = [
            '#FFEBEE'
            '#FFCDD2'
            '#EF9A9A'
            '#E57373'
            '#EF5350'
            '#F44336'
            '#E53935'
            '#D32F2F'
            '#C62828'
            '#B71C1C'
        ];

        cPink = [
            '#FCE4EC'
            '#F8BBD0'
            '#F48FB1'
            '#F06292'
            '#EC407A'
            '#E91E63'
            '#D81B60'
            '#C2185B'
            '#AD1457'
            '#880E4F'
        ];

        cPurple = [
            '#F3E5F5'
            '#E1BEE7'
            '#CE93D8'
            '#BA68C8'
            '#AB47BC'
            '#9C27B0'
            '#8E24AA'
            '#7B1FA2'
            '#6A1B9A'
            '#4A148C'
        ];

        cDeepPurple = [
            '#EDE7F6'
            '#D1C4E9'
            '#B39DDB'
            '#9575CD'
            '#7E57C2'
            '#673AB7'
            '#5E35B1'
            '#512DA8'
            '#4527A0'
            '#311B92'
        ];

        cIndigo = [
            '#E8EAF6'
            '#C5CAE9'
            '#9FA8DA'
            '#7986CB'
            '#5C6BC0'
            '#3F51B5'
            '#3949AB'
            '#303F9F'
            '#283593'
            '#1A237E'
        ];

        cBlue = [
            '#E3F2FD'
            '#BBDEFB'
            '#90CAF9'
            '#64B5F6'
            '#42A5F5'
            '#2196F3'
            '#1E88E5'
            '#1976D2'
            '#1565C0'
            '#0D47A1'
        ];

        cLightBlue = [
            '#E1F5FE'
            '#B3E5FC'
            '#81D4FA'
            '#4FC3F7'
            '#29B6F6'
            '#03A9F4'
            '#039BE5'
            '#0288D1'
            '#0277BD'
            '#01579B'
        ];

        cCyan = [
            '#E0F7FA'
            '#B2EBF2'
            '#80DEEA'
            '#4DD0E1'
            '#26C6DA'
            '#00BCD4'
            '#00ACC1'
            '#0097A7'
            '#00838F'
            '#006064'
        ];

        cTeal = [
            '#E0F2F1'
            '#B2DFDB'
            '#80CBC4'
            '#4DB6AC'
            '#26A69A'
            '#009688'
            '#00897B'
            '#00796B'
            '#00695C'
            '#004D40'
        ];

        cGreen = [
            '#E8F5E9'
            '#C8E6C9'
            '#A5D6A7'
            '#81C784'
            '#66BB6A'
            '#4CAF50'
            '#43A047'
            '#388E3C'
            '#2E7D32'
            '#1B5E20'
        ];

        cLightGreen = [
            '#F1F8E9'
            '#DCEDC8'
            '#C5E1A5'
            '#AED581'
            '#9CCC65'
            '#8BC34A'
            '#7CB342'
            '#689F38'
            '#558B2F'
            '#33691E'
        ];

        cLime = [
            '#F9FBE7'
            '#F0F4C3'
            '#E6EE9C'
            '#DCE775'
            '#D4E157'
            '#CDDC39'
            '#C0CA33'
            '#AFB42B'
            '#9E9D24'
            '#827717'
        ];

        cYellow = [
            '#FFFDE7'
            '#FFF9C4'
            '#FFF59D'
            '#FFF176'
            '#FFEE58'
            '#FFEB3B'
            '#FDD835'
            '#FBC02D'
            '#F9A825'
            '#F57F17'
        ];

        cAmber = [
            '#FFF8E1'
            '#FFECB3'
            '#FFE082'
            '#FFD54F'
            '#FFCA28'
            '#FFC107'
            '#FFB300'
            '#FFA000'
            '#FF8F00'
            '#FF6F00'
        ];

        cOrange = [
            '#FFF3E0'
            '#FFE0B2'
            '#FFCC80'
            '#FFB74D'
            '#FFA726'
            '#FF9800'
            '#FB8C00'
            '#F57C00'
            '#EF6C00'
            '#E65100'
        ];

        cDeepOrange = [
            '#FBE9E7'
            '#FFCCBC'
            '#FFAB91'
            '#FF8A65'
            '#FF7043'
            '#FF5722'
            '#F4511E'
            '#E64A19'
            '#D84315'
            '#BF360C'
        ];

        cBrown = [
            '#EFEBE9'
            '#D7CCC8'
            '#BCAAA4'
            '#A1887F'
            '#8D6E63'
            '#795548'
            '#6D4C41'
            '#5D4037'
            '#4E342E'
            '#3E2723'
        ];

        cGray = [
            '#FAFAFA'
            '#F5F5F5'
            '#EEEEEE'
            '#E0E0E0'
            '#BDBDBD'
            '#9E9E9E'
            '#757575'
            '#616161'
            '#424242'
            '#212121'
        ];

        cBlueGray = [
            '#ECEFF1'
            '#CFD8DC'
            '#B0BEC5'
            '#90A4AE'
            '#78909C'
            '#607D8B'
            '#546E7A'
            '#455A64'
            '#37474F'
            '#263238'
        ];
    end

    methods(Static)
        function color = red(variant)
            color = Color(MaterialColors.cRed(MaterialColors.mapVariant(variant), :));
        end

        function color = pink(variant)
            color = Color(MaterialColors.cPink(MaterialColors.mapVariant(variant), :));
        end

        function color = purple(variant)
            color = Color(MaterialColors.cPurple(MaterialColors.mapVariant(variant), :));
        end

        function color = deepPurple(variant)
            color = Color(MaterialColors.cDeepPurple(MaterialColors.mapVariant(variant), :));
        end

        function color = indigo(variant)
            color = Color(MaterialColors.cIndigo(MaterialColors.mapVariant(variant), :));
        end

        function color = blue(variant)
            color = Color(MaterialColors.cBlue(MaterialColors.mapVariant(variant), :));
        end

        function color = lightBlue(variant)
            color = Color(MaterialColors.cLightBlue(MaterialColors.mapVariant(variant), :));
        end

        function color = cyan(variant)
            color = Color(MaterialColors.cCyan(MaterialColors.mapVariant(variant), :));
        end

        function color = teal(variant)
            color = Color(MaterialColors.cTeal(MaterialColors.mapVariant(variant), :));
        end

        function color = green(variant)
            color = Color(MaterialColors.cTreen(MaterialColors.mapVariant(variant), :));
        end

        function color = lightGreen(variant)
            color = Color(MaterialColors.cLightGreen(MaterialColors.mapVariant(variant), :));
        end

        function color = lime(variant)
            color = Color(MaterialColors.cLime(MaterialColors.mapVariant(variant), :));
        end

        function color = yellow(variant)
            color = Color(MaterialColors.cYellow(MaterialColors.mapVariant(variant), :));
        end

        function color = amber(variant)
            color = Color(MaterialColors.cAmber(MaterialColors.mapVariant(variant), :));
        end

        function color = orange(variant)
            color = Color(MaterialColors.cOrange(MaterialColors.mapVariant(variant), :));
        end

        function color = deepOrange(variant)
            color = Color(MaterialColors.cDeepOrange(MaterialColors.mapVariant(variant), :));
        end

        function color = brown(variant)
            color = Color(MaterialColors.cBrown(MaterialColors.mapVariant(variant), :));
        end

        function color = gray(variant)
            color = Color(MaterialColors.cGray(MaterialColors.mapVariant(variant), :));
        end

        function color = grey(variant)
            color = MaterialColors.gray(variant);
        end

        function color = blueGray(variant)
            color = Color(MaterialColors.cBlueGray(MaterialColors.mapVariant(variant), :));
        end

        function color = blueGrey(variant)
            color = MaterialColors.blueGray(variant);
        end
    end

    methods(Static, Access=private)
        function index = mapVariant(variant)
            MaterialColors.validateVariant(variant)

            switch variant
                case 50
                    index = 1;
                otherwise
                    index = floor(variant / 100) + 1;
            end
        end

        function validateVariant(variant)
            if (mod(variant, 100) ~= 0 || variant > 900) && variant ~= 50
                error('Color variant must be a valid Material UI color variant');
            end
        end
    end
end
