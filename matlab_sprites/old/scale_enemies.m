
clear
close all

name = 'MyEnemiesScaled';
inp = 'MyEnemiesFullSize.bmp';
[A,MAP] = imread(inp);


All=[];

d=128;

for t=1:11

    I = A((t-1)*40+(1:40),1:40);

    figure;

    Fr = [];
    
    for s=0:15

        SQ = uint8(zeros(size(I)));
        scale = d/(d+s*40);
        
        J = imresize(I, scale, 'nearest');

        u = 1 + floor(size(SQ,2)/2-size(J,2)/2);
        v = 1 + floor(size(SQ,1)/2-size(J,1)/2);

        SQ(v:(v+size(J,1)-1),u:(u+size(J,2)-1)) = J;

        image(SQ);
        axis equal;
        colormap(MAP);
        pause;
        
        SQ = uint8(zeros(size(I)));
        
        u = 1;
        v = 1;
        SQ(v:(v+size(J,1)-1),u:(u+size(J,2)-1)) = J;

        Fr = [Fr SQ ];
    end

    All = [All; Fr];
end

imwrite(All,MAP,[name '.bmp']);

% add F14 (9 frames 48x32)
%All = [A(:,1:(64*9)) All];

%imwrite(All,MAP,[name '.bmp']);

return
