
function ScaleSprite()

    clear
    close all

    name = 'ExplosionsScaled';
    inp = 'Explosion4F_48x48.bmp';
    [A,MAP] = imread(inp);
    
    FSize = size(A,2);
    Nframe   = size(A,1)/FSize;

    %t=-15:14;
    %myc=round(256*cos(t*2*pi/30)');
    %mys=round(256*sin(t*2*pi/30)');

    figure;

    All=[];
    d = 64;

    for t=1:Nframe
        B = A((1:FSize)+(t-1)*FSize,:);
        image(B);
        colormap(MAP);
        axis equal;

        I = B;
        Fr = [];

        for s=0:15

            SQ = uint8(zeros(size(I)));
            scale = d/(d+(360/16)*s);

            J = imresize(I, scale, 'nearest');

            u = 1 + floor(size(SQ,2)/2-size(J,2)/2);
            v = 1 + floor(size(SQ,1)/2-size(J,1)/2);

            SQ(v:(v+size(J,1)-1),u:(u+size(J,2)-1)) = J;

            image(SQ);
            axis equal;
            colormap(MAP);
            pause(0.1);

            SQ = uint8(zeros(size(I)));

            u = 1;
            v = 1;
            SQ(v:(v+size(J,1)-1),u:(u+size(J,2)-1)) = J;

            if (max(size(J))<9) 
                tt = SQ(:);
                [~,ty,tv] = find(tt);
                [N,e] = histcounts(tv,'BinMethod','integers');
                [u,v] = max(N);
                 if (u>0)
                     SQ(SQ>0) = (e(v)+e(v+1))/2;
                 end

%                 for y=1:size(SQ,1)
%                     tt = SQ(y,:);
%                     [~,ty,tv] = find(tt);
%                     [N,e] = histcounts(tv,'BinMethod','integers');
%                     [u,v] = max(N);
%                      if (u>0)
%                          SQ(y,ty) = (e(v)+e(v+1))/2;
%                      end
%                 end

            end

            Fr = [Fr SQ ];
        end

        All = [All; Fr];
    end

    imwrite(All,MAP,[name '.bmp']);
end

