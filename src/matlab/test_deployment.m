% TEST_DEPLOYMENT.M
% Final MathWorks SIH 26038 Compliance Launcher
% This script launches the fully interactive Virtual Clinic Application.
% Do NOT run as a procedural script. Instead, it acts as the entry point
% for the doctor's graphical user interface.

clc; clear; close all;

fprintf('=== eDRis MATLAB Deployment Launcher ===\n\n');
fprintf('Booting the Virtual Clinic Interactive Application...\n');
fprintf('Please interact directly with the graphical user interface.\n');

% Launch the true interactive UI Application
virtual_clinic_app();

