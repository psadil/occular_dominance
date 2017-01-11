function [ output_args ] = makeMondrians( input_args )
%makeMondrians create mask of mondrians
%   Contrast values will be adjusted during the presentation of the mask


p.colors = permute(hsv2rgb(permute(cat(2,randi(6,p.nSuppressors,1,p.nSlides)*(1/6),randi(6,p.nSuppressors,1,p.nSlides)*(1/6),randi(6,p.nSuppressors,1,p.nSlides)*(1/6)),...
    [1 3 2])),[3 1 2]);
% p.colors = permute(hsv2rgb(permute(cat(2,randi(1,p.nSuppressors,1,p.nSlides),randi(1,p.nSuppressors,1,p.nSlides),randi(1,p.nSuppressors,1,p.nSlides)),[1 3 2])),[3 1 2]);


p.leftRect = CenterRect([0 0 totalFrame-maxL totalFrame-maxL],Screen('Rect',p.window));
p.rightRect = p.leftRect;
p.imageRect = CenterRect([0 0 imageFrame imageFrame],Screen('Rect',p.window));
p.whiteRect = CenterRect([0 0 totalFrame+whiteRectBorder totalFrame+whiteRectBorder],Screen('Rect',p.window));
% p.whiteTex = Screen('MakeTexture',p.window,1);
p.greyRect = CenterRect([0 0 totalFrame totalFrame],Screen('Rect',p.window));
% p.greyTex = Screen('MakeTexture',p.window,161/255);

% Generate suppressor rectangles, images, and other variables
p.mondrians(1,:,:) = randi([-maxL,totalFrame],[1, p.nSuppressors, p.nSlides]);
p.mondrians(2,:,:) = randi([-maxL,totalFrame],[1, p.nSuppressors, p.nSlides]);
p.mondrians(3,:,:) = min(p.mondrians(1,:,:) + repmat(minL,[1,p.nSuppressors,p.nSlides]) + randi(maxL-minL,[1,p.nSuppressors,p.nSlides]),totalFrame);
p.mondrians(4,:,:) = min(p.mondrians(2,:,:) + repmat(minL,[1,p.nSuppressors,p.nSlides]) + randi(maxL-minL,[1,p.nSuppressors,p.nSlides]),totalFrame);



end

