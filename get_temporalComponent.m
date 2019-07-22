%%
function [Y_r, C] = get_temporalComponent(Y,A,C,b,f,Cn,options)

memmaped = isobject(Y);
defoptions = CNMFSetParms;
if nargin < 7 || isempty(options); options = []; end
if ~isfield(options,'d1') || isempty(options.d1); d1 = input('What is the total number of rows? \n'); else d1 = options.d1; end          % # of rows
if ~isfield(options,'d2') || isempty(options.d2); d2 = input('What is the total number of columns? \n'); else d2 = options.d2; end          % # of columns
% if ~isfield(options,'normalize') || isempty(options.normalize); options.normalize = ones(size(A,1),1); end
%     sn = options.normalize;
if ~isfield(options,'plot_df') || isempty(options.plot_df); options.df = defoptions.plot_df; end
plot_df = options.plot_df;
if ~isfield(options,'make_gif') || isempty(options.make_gif); options.make_gif = defoptions.make_gif; end
make_gif = options.make_gif;
if ~isfield(options,'save_avi') || isempty(options.save_avi); options.save_avi = defoptions.save_avi; end
save_avi = options.save_avi;
if ~isfield(options,'sx') || isempty(options.sx); options.sx = defoptions.sx; end
sx = min([options.sx,floor(d1/2),floor(d2/2)]);
%if ~isfield(options,'pause_time') || isempty(options.pause_time); options.pause_time = defoptions.pause_time; end
%pause_time = options.pause_time;
if isfield(options,'name') && ~isempty(options.name);
    name = [options.name,'_components'];
else
    name = [defoptions.name,'_components'];
end
if ~isfield(options,'full_A') || isempty(options.full_A); full_A = defoptions.full_A; else full_A = options.full_A; end

T = size(C,2);
if ndims(Y) == 3
    Y = reshape(Y,d1*d2,T);
end
if nargin < 6 || isempty(Cn);
    Cn = reshape(mean(Y,2),d1,d2);
end
b = double(b);
C = double(C);
f = double(f);
nA = full(sqrt(sum(A.^2))');
[K,~] = size(C);
A = A/spdiags(nA,0,K,K);    % normalize spatial components to unit energy
C = bsxfun(@times,C,nA(:)); %spdiags(nA,0,K,K)*C;

nr = size(A,2);     % number of ROIs
nb = size(f,1);     % number of background components
%nA = full(sum(A.^2))';  % energy of each row
%Y_r = spdiags(nA,0,nr,nr)\(A'*Y- (A'*A)*C - (A'*full(b))*f) + C; 

step = 5e3;
if memmaped
    AY = zeros(K,T);
    for i = 1:step:d
        AY = AY + A(i:min(i+step-1,d),:)'*double(Y.Yr(i:min(i+step-1,d),:));
    end
else
    if issparse(A) && isa(Y,'single')  
        if full_A
            AY = full(A)'*Y;
        else
            AY = A'*double(Y);
        end
    else
        AY = A'*Y;
    end
end
Y_r = (AY- (A'*A)*C - full(A'*double(b))*f) + C;

end