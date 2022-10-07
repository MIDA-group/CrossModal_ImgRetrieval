function [patches, varargout] = splitImageIntoPatches(img, patch_size)
% returns the patches row-wise from top to bottom
% optional output is number of [horizontal, vertical] patches
% returns original image if that is already of the size patch_size

 %   assert(ismatrix(img), 'This only works with 2D images right now.');
    sz = size(img);
    sz(1:2) = patch_size; %now sz may have a third dim (if img is rgb)
    if (length(patch_size) > 2)
        error('Bad patch_size, needs to be a scalar or [w, h]');
    end
    nh = ceil(size(img,2)/sz(1)); % no horizontally distributed patches
    nv = ceil(size(img,1)/sz(2)); % no vertical patches
    % make sure patches are the same class and type as img
    dimsImg = ndims(img);
    imgS.subs = repmat({':'}, 1, dimsImg);
    imgS.type = '()';
    patchS.subs = repmat({':'}, 1, dimsImg+1);
    patchS.type = '()';

    patches = cast(zeros([sz, nh*nv]), 'like', img);
    
    % calc (pixel) offsets for horizontal patches..
    if nh>1
        dh = (nh*sz(1) - size(img,2))/(nh-1);
    end
    ho = ones(1,nh);
    for i = 2:nh-1; ho(i) = round((i-1)*(sz(1)-dh)); end
    ho(end) = size(img,2)-sz(1)+1;
    
    % ..and the vertical ones
    if nv>1
        dv = (nv*sz(2) - size(img,1))/(nv-1);
    end
    vo = ones(1,nv);
    for i = 2:nv-1; vo(i) = round((i-1)*(sz(2)-dv)); end
    vo(end) = size(img,1)-sz(2)+1;
    % fetch the patches
    for i = 1:nv
        for j = 1:nh
            imgS.subs{1} = vo(i)+(0:sz(2)-1); 
            imgS.subs{2} = ho(j)+(0:sz(1)-1); % the third one is '':'' if it exists
            patchS.subs{dimsImg+1} = (i-1)*nh+j; % all the others are '':''

            patches = subsasgn(patches,patchS, subsref(img,imgS));
        end
    end
    %fprintf("\n img size: %d x %d, patch size:  %d x %d, nr patches: %d\n", size(img,1), size(img,2), sz(1), sz(2), nh*nv);
    if (nargout > 1); varargout{1} = [nh, nv]; end
end
