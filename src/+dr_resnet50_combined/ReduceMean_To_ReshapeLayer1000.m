classdef ReduceMean_To_ReshapeLayer1000 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.

    %#ok<*PROPLC>
    %#ok<*NBRAK>
    %#ok<*INUSL>
    %#ok<*VARARG>
    properties (Learnable)
    end

    properties (State)
    end

    properties
        Vars
        NumDims
    end




    methods
        function this = ReduceMean_To_ReshapeLayer1000(name)
            this.Name = name;
            this.OutputNames = {'view'};
        end

        function [view] = predict(this, relu_48)
            if isdlarray(relu_48)
                relu_48 = stripdims(relu_48);
            end
            relu_48NumDims = 4;
            relu_48 = dr_resnet50_combined.ops.permuteInputVar(relu_48, [4 3 1 2], 4);

            [view, viewNumDims] = ReduceMean_To_ReshapGraph1000(this, relu_48, relu_48NumDims, false);
            view = dr_resnet50_combined.ops.permuteOutputVar(view, [2 1], 2);

            view = dlarray(single(view), 'CB');
        end

        function [view] = forward(this, relu_48)
            if isdlarray(relu_48)
                relu_48 = stripdims(relu_48);
            end
            relu_48NumDims = 4;
            relu_48 = dr_resnet50_combined.ops.permuteInputVar(relu_48, [4 3 1 2], 4);

            [view, viewNumDims] = ReduceMean_To_ReshapGraph1000(this, relu_48, relu_48NumDims, true);
            view = dr_resnet50_combined.ops.permuteOutputVar(view, [2 1], 2);

            view = dlarray(single(view), 'CB');
        end

        function [view, viewNumDims1001] = ReduceMean_To_ReshapGraph1000(this, relu_48, relu_48NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_resnet50_combined.ops.prepareReduceArgs(this.Vars.val_589, relu_48NumDims);
            mean1000 = mean(relu_48, dims);
            mean1000NumDims = relu_48NumDims;

            % Reshape:
            [shape, viewNumDims] = dr_resnet50_combined.ops.prepareReshapeArgs(mean1000, this.Vars.val_593, mean1000NumDims, 1);
            view = reshape(mean1000, shape{:});

            % Set graph output arguments
            viewNumDims1001 = viewNumDims;

        end

    end

end