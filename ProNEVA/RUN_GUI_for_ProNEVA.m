%-------------------------------------------------------------------------
%                           RUN ProNEVA
%-------------------------------------------------------------------------
%
%Reference Publication: Ragno E, AghaKouchak A, Cheng L, Sadegh M, 2019,
%A Generalized Framework for Process-informed Nonstationary Extreme
%Value Analysis, Advances in Water Resources, in revision.
%
% ProNEVA MATLAB code is developed by Elisa Ragno University of California, Irvine
%
% For questions and permissions, please contact Amir AghaKouchak
% (amir.a@uci.edu) or Elisa Ragno (E.Ragno@tudelft.nl)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Disclaimer:} The Process-informed Nonstationary Extreme Value Analysis
%(ProNEVA) software package is provided `as is' without any endorsement
%made and without warranty of any kind, either express or implied. While
%we strive to ensure that ProNEVA is accurate, no guarantees for the
%accuracy of the codes, output information and figures are made. ProNEVA
%codes and outputs can only be used at your own discretion and risk and
%with agreement that you will be solely responsible for any damage and that
%the authors and their affiliate institutions accept no responsibility for errors or omissions
%in ProNEVA codes, outputs, figures, and documentation. In no event shall
%the authors, developers or their affiliate institutions be liable to you
%or any third parties for any special, direct, indirect or consequential
%damages and financial risks of any kind, or any damages whatsoever,
%resulting from, arising out of or in connection with the use of ProNEVA.
%The user of ProNEVA agrees that the codes and algorithms are subject to
%change without notice.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Erease previous messages
clc;

currentDIR = pwd();                 % Current Directory     
cd('GUIpackage');                   % Open Folder w/ GUIs
save('currentDIR.mat', 'currentDIR')  % Save Original Directory 

ProNEVA_GUI_MAIN;                   % Run GUI

% add default values for prior and parameters
% threshold GP

