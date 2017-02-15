function [ keys ] = setupKeys(  )
%setupKeys setup different kinds of useful key patterns


codes = zeros(1,256);

keys.arrows = codes;
keys.arrows(KbName({'LeftArrow','RightArrow'})) = 1;
keys.escape = codes;
keys.escape(KbName('ESCAPE')) = 1;
keys.space = codes;
keys.space(KbName({'space'})) = 1;

end

