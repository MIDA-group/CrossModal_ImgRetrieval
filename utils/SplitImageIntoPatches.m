function [patches, varargout] = SplitImageIntoPatches(img, patch_size)
% returns the patches row-wise from top to bottom
% optional output is number of [horizontal, vertical] patches
    assert(ismatrix(img), 'This only works with 2D images right now.');
    if (length(patch_size) == 2); sz = patch_size;
    elseif (length(patch_size) == 1); sz = [1,1] .* patch_size;
    else; error('Bad patch_size, needs to be a scalar or [w, h]');
    end
    nh = ceil(size(img,2)/sz(1)); % no horizontally distributed patches
    nv = ceil(size(img,1)/sz(2)); % no vertical patches
    % make sure patches are the same class and type as img
    patches = cast(zeros(sz(1), sz(2), nh*nv), 'like', img);
    % calc (pixel) offsets for horizontal patches..
    dh = (nh*sz(1) - size(img,2))/(nh-1);
    ho = ones(1,nh);
    for i = 2:nh-1; ho(i) = round((i-1)*(sz(1)-dh)); end
    ho(end) = size(img,2)-sz(1)+1;
    % ..and the vertical ones
    dv = (nv*sz(2) - size(img,1))/(nv-1);
    vo = ones(1,nv);
    for i = 2:nv-1; vo(i) = round((i-1)*(sz(2)-dv)); end
    vo(end) = size(img,1)-sz(2)+1;
    % fetch the patches
    for i = 1:nv
        for j = 1:nh
            patches(:,:,(i-1)*nh+j) = img(vo(i)+(0:sz(2)-1), ...
                                          ho(j)+(0:sz(1)-1));
        end
    end
    if (nargout > 1); varargout{1} = [nh, nv]; end
end
