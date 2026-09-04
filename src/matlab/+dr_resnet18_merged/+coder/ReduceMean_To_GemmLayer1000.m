classdef ReduceMean_To_GemmLayer1000 < nnet.layer.Layer & nnet.layer.Formattable
    % A custom layer auto-generated while importing an ONNX network.
    %#codegen

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
        % Specify the properties of the class that will not be modified
        % after the first assignment.
        function p = matlabCodegenNontunableProperties(~)
            p = {
                % Constants, i.e., Vars, NumDims and all learnables and states
                'Vars'
                'NumDims'
                };
        end
    end


    methods(Static, Hidden)
        % Instantiate a codegenable layer instance from a MATLAB layer instance
        function this_cg = matlabCodegenToRedirected(mlInstance)
            this_cg = dr_resnet18_merged.coder.ReduceMean_To_GemmLayer1000(mlInstance);
        end
        function this_ml = matlabCodegenFromRedirected(cgInstance)
            this_ml = dr_resnet18_merged.ReduceMean_To_GemmLayer1000(cgInstance.Name);
            if isstruct(cgInstance.Vars)
                names = fieldnames(cgInstance.Vars);
                for i=1:numel(names)
                    fieldname = names{i};
                    this_ml.Vars.(fieldname) = dlarray(cgInstance.Vars.(fieldname));
                end
            else
                this_ml.Vars = [];
            end
            this_ml.NumDims = cgInstance.NumDims;
            this_ml.fc_weight = cgInstance.fc_weight;
            this_ml.fc_bias = cgInstance.fc_bias;
        end
    end

    methods
        function this = ReduceMean_To_GemmLayer1000(mlInstance)
            this.Name = mlInstance.Name;
            this.NumInputs = 2;
            this.OutputNames = {'output'};
            if isstruct(mlInstance.Vars)
                names = fieldnames(mlInstance.Vars);
                for i=1:numel(names)
                    fieldname = names{i};
                    this.Vars.(fieldname) = dr_resnet18_merged.coder.ops.extractIfDlarray(mlInstance.Vars.(fieldname));
                end
            else
                this.Vars = [];
            end

            this.NumDims = mlInstance.NumDims;
            this.fc_weight = mlInstance.fc_weight;
            this.fc_bias = mlInstance.fc_bias;
        end

        function [output] = predict(this, input__, relu_16__)
            if isdlarray(input__)
                input_ = stripdims(input__);
            else
                input_ = input__;
            end
            if isdlarray(relu_16__)
                relu_16_ = stripdims(relu_16__);
            else
                relu_16_ = relu_16__;
            end
            inputNumDims = 4;
            relu_16NumDims = 4;
            input = dr_resnet18_merged.coder.ops.permuteInputVar(input_, [4 3 1 2], 4);
            relu_16 = dr_resnet18_merged.coder.ops.permuteInputVar(relu_16_, [4 3 1 2], 4);

            [output__, outputNumDims__] = ReduceMean_To_GemmGraph1000(this, input, relu_16, inputNumDims, relu_16NumDims, false);
            output_ = dr_resnet18_merged.coder.ops.permuteOutputVar(output__, ['as-is'], 2);

            output = dlarray(single(output_), repmat('U', 1, max(2, coder.const(outputNumDims__))));
        end

        function [output, outputNumDims1003] = ReduceMean_To_GemmGraph1000(this, input, relu_16, inputNumDims, relu_16NumDims, Training)

            % Execute the operators:
            % ReduceMean:
            dims1000 = dr_resnet18_merged.coder.ops.prepareReduceArgs(this.Vars.val_188, coder.const(relu_16NumDims));
            xReduced1001 = mean(relu_16, dims1000);
            mean1000 = xReduced1001;
            mean1000NumDims = coder.const(relu_16NumDims);

            % Shape:
            [val_0, val_0NumDims] = dr_resnet18_merged.coder.ops.onnxShape(input, coder.const(inputNumDims), 0, 1);

            % Concat:
            [val_192, val_192NumDims] = dr_resnet18_merged.coder.ops.onnxConcat(0, {val_0, this.Vars.val_191}, [coder.const(val_0NumDims), this.NumDims.val_191]);

            % Reshape:
            [shape1002, viewNumDims] = dr_resnet18_merged.coder.ops.prepareReshapeArgs(mean1000, val_192, coder.const(mean1000NumDims), 1);
            view = reshape(mean1000, shape1002{:});

            % Gemm:
            [A1003, B1004, C1005, alpha1006, beta1007, outputNumDims] = dr_resnet18_merged.coder.ops.prepareGemmArgs(view, this.fc_weight, this.fc_bias, this.Vars.Gemmalpha1001, this.Vars.Gemmbeta1002, 0, 1, this.NumDims.fc_bias);
            output = alpha1006*B1004*A1003 + beta1007*C1005;

            % Set graph output arguments
            outputNumDims1003 = coder.const(outputNumDims);

        end

    end

end