classdef NetworkPersistor < handle

    properties
        hdfName
        name
    end

    methods
        function obj = NetworkPersistor(hdfName, name)
            obj.hdfName = hdfName;
            obj.name = name;

            if ~exist(hdfName, 'file')
                h5tools.createFile(hdfName);
            end
            h5tools.createGroup(hdfName, '/', name);
            h5tools.createGroup(hdfName, ['/' name],...
                'data', 'hyperparameters', 'network', 'performance');
            h5tools.writeatt(hdfName, name, 'DateCreated', datestr(now));
        end

        function addCombinedDatastores(obj, dsTrain, dsTest, dsVal)
            arguments
                obj         (1,1)   NetworkPersistor
                dsTrain             matlab.io.Datastore
                dsTest              matlab.io.Datastore     = []
                dsVal               matlab.io.Datastore     = []
            end

            h5tools.createGroup(obj.hdfName, ['/' obj.name '/data'], 'train', 'test', 'val');

            dsTrain.reset();
            T = dsTrain.readall();
            h5tools.write(obj.hdfName, ['/' obj.name '/data/train'], 'Images', vertcat(T.InputImage));

            if nargin > 2 && ~isempty(dsTest)
                dsTest.reset();
                T = dsTest.readall();
                h5tools.createGroup(obj.hdfName, ['/' obj.name '/data'], 'test');
                h5tools.createGroup(obj.hdfName, ['/' obj.name '/data/test'], 'Images', 'Labels')
                h5tools.write(obj.hdfName, ['/' obj.name '/data/test'], 'Images', vertcat(T.InputImage));
            end

            if nargin > 3 || ~isempty(dsVal)
                dsVal.reset();
                T = dsVal.readall();
                h5tools.createGroup(obj.hdfName, ['/' obj.name '/data'], 'validation');
                h5tools.createGroup(obj.hdfName, ['/' obj.name '/data/validation'], 'Images', 'Labels')
                h5tools.write(obj.hdfName, ['/' obj.name '/data/validation'],...
                    'Images', cat(3, T.InputImage));
            end
        end

        function addRawData(obj, dsetName, image, label)
            if ~h5tools.exists(obj.hdfName, ['/' obj.name '/data/raw'])
                h5tools.createGroup(obj.hdfName, ['/' obj.name '/data'], 'raw');
                h5tools.createGroup(obj.hdfName, ['/' obj.name '/data/raw'], 'images', 'labels');
            end

            h5tools.write(obj.hdfName, ['/' obj.name '/data/raw/images'], dsetName, image);
            h5tools.write(obj.hdfName, ['/' obj.name '/data/raw/labels'], dsetName, label);
        end

        function addOptimization(obj, optimizer)
            arguments
                obj         (1,1)       NetworkPersistor
                optimizer   (1,1)       nnet.cnn.TrainingOptions
            end

            opts = obj.props2map(optimizer, 'ValidationData');
            optimType = extractAfter(class(optimizer), 'nnet.cnn.TrainingOptions');
            h5tools.write(obj.hdfName, ['/' obj.name '/hyperparameters'],...
                optimType, opts);
        end

        function addNetwork(obj, net)
            arguments
                obj     (1,1)       NetworkPersistor
                net     (1,1)       net.cnn.network.HeterogeneousDAGNetwork
            end

            % Add the individual layers
            obj.addLayers(net.Layers);
            % Document the connections between each layer
            T = net.Connections;
            T.Source = string(T.Source);
            T.Destination = string(T.Destination);
            h5tools.write(obj.hdfName, ['/' obj.name '/network'], 'Connections', T);
        end

        function addLayers(obj, layers)
            allNames = [];
            for i = 1:numel(layers)
                layer = layers(i);
                layerName = layer.Name;
                allNames = cat(1, allNames, string(layerName));
                obj.addLayer(layer);
            end
            h5tools.write(obj.hdfName, ['/' obj.name '/network'], 'LayerNames', allNames);
        end

        function addLayer(obj, layer)
            arguments
                obj     (1,1)       NetworkPersistor
                layer   (1,1)       nnet.cnn.layer.Layer
            end

            proxy = nnet.internal.cnn.analyzer.util.LayerProxy(layer);
            layerPath = ['/' obj.name '/network/' proxy.Name];
            h5tools.createGroup(obj.hdfName, layerPath, proxy.Name);
            h5tools.writeatt(obj.hdfName, layerPath,...
                'Type', proxy.Type, 'Class', class(layer),...
                'Name', proxy.Name, 'Description', proxy.Description);
            h5tools.createGroup(obj.hdfName, layerPath,...
                'Hyperparameters', 'DynamicParameters',...
                'LearnableParameters', 'Properties');
            for i = 1:numel(proxy.Hyperparameters)
                h5tools.write(obj.hdfName, layerPath,...
                    proxy.Hyperparameters(i), layer.Hyperparameters(i));
            end
            for i = 1:numel(proxy.DynamicParameters)
                h5tools.write(obj.hdfName, layerPath,...
                    proxy.DynamicParameters(i), layer.DynamicParameters(i));
            end
            for i = 1:numel(proxy.LearnableParameters)
                h5tools.write(obj.hdfName, layerPath,...
                    proxy.LearnableParameters(i), layer.LearnableParameters(i));
            end
            for i = 1:numel(proxy.Properties)
                h5tools.write(obj.hdfName, layerPath,...
                    proxy.Properties(i), layer.Properties(i));
            end
        end
    end

    methods (Static)
        function out = props2map(input, ignoredProps)
            props = properties(input);
            props = setdiff(props, ignoredProps);
            out = containers.Map();
            for i = 1:length(props)
                out(props{i}) = input.(props{i});
            end
        end
    end
end