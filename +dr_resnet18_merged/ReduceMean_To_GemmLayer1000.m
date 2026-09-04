classdef ReduceMean_To_GemmLayer1000 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.

    %#ok<*PROPLC>
    %#ok<*NBRAK>
    %#ok<*INUSL>
    %#ok<*VARARG>
    properties (Learnable)
        fc_weight
        fc_bias
    end

    properties (State)
    end

    properties
        Vars
        NumDims
    end


    methods(Static, Hidden)
        % Specify the path to the class that will be used for codegen
        function name = matlabCodegenRedirect(~)
            name = 'dr_resnet18_merged.coder.ReduceMean_To_GemmLayer1000';
        end
    end


    methods
        function this = ReduceMean_To_GemmLayer1000(name)
            this.Name = name;
            this.NumInputs = 2;
            this.OutputNames = {'output'};
        end

        function [output] = predict(this, input, relu_16)
            if isdlarray(input)
                input = stripdims(input);
            end
            if isdlarray(relu_16)
                relu_16 = stripdims(relu_16);
            end
            inputNumDims = 4;
            relu_16NumDims = 4;
            input = dr_resnet18_merged.ops.permuteInputVar(input, [4 3 1 2], 4);
            relu_16 = dr_resnet18_merged.ops.permuteInputVar(relu_16, [4 3 1 2], 4);

            [output, outputNumDims] = ReduceMean_To_GemmGraph1000(this, input, relu_16, inputNumDims, relu_16NumDims, false);
            output = dr_resnet18_merged.ops.permuteOutputVar(output, ['as-is'], 2);

            output = dlarray(single(output), repmat('U', 1, max(2, outputNumDims)));
        end

        function [output] = forward(this, input, relu_16)
            if isdlarray(input)
                input = stripdims(input);
            end
            if isdlarray(relu_16)
                relu_16 = stripdims(relu_16);
            end
            inputNumDims = 4;
            relu_16NumDims = 4;
            input = dr_resnet18_merged.ops.permuteInputVar(input, [4 3 1 2], 4);
            relu_16 = dr_resnet18_merged.ops.permuteInputVar(relu_16, [4 3 1 2], 4);

            [output, outputNumDims] = ReduceMean_To_GemmGraph1000(this, input, relu_16, inputNumDims, relu_16NumDims, true);
            output = dr_resnet18_merged.ops.permuteOutputVar(output, ['as-is'], 2);

            output = dlarray(single(output), repmat('U', 1, max(2, outputNumDims)));
        end

        function [output, outputNumDims1003] = ReduceMean_To_GemmGraph1000(this, input, relu_16, inputNumDims, relu_16NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims = dr_resnet18_merged.ops.prepareReduceArgs(this.Vars.val_188, relu_16NumDims);
            mean1000 = mean(relu_16, dims);
            mean1000NumDims = relu_16NumDims;

            % Shape:
            [val_0, val_0NumDims] = dr_resnet18_merged.ops.onnxShape(input, inputNumDims, 0, 1);

            % Concat:
            [val_192, val_192NumDims] = dr_resnet18_merged.ops.onnxConcat(0, {val_0, this.Vars.val_191}, [val_0NumDims, this.NumDims.val_191]);

            % Reshape:
            [shape, viewNumDims] = dr_resnet18_merged.ops.prepareReshapeArgs(mean1000, val_192, mean1000NumDims, 1);
            view = reshape(mean1000, shape{:});

            % Gemm:
            [A, B, C, alpha, beta, outputNumDims] = dr_resnet18_merged.ops.prepareGemmArgs(view, this.fc_weight, this.fc_bias, this.Vars.Gemmalpha1001, this.Vars.Gemmbeta1002, 0, 1, this.NumDims.fc_bias);
            output = alpha*B*A + beta*C;

            % Set graph output arguments
            outputNumDims1003 = outputNumDims;

        end

    end

end