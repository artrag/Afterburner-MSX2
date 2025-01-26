
function TiltSprite()

    clear
    close all

    name = 'MyEnemiesScaled2';
    inp = 'EnemyFullSizeNoTilt_2_48x48.bmp';
    [A,MAP] = imread(inp);
    
    figure;

    All=[];
    d = 64;

    for tilt=-15:14
        a = -tilt*360/30;
        B = imrotate(A,a,'nearest','crop');
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

            if (max(size(J))<11) 
                for y=1:size(SQ,1)
                    tt = SQ(y,:);
                    [~,ty,tv] = find(tt);
                    [N,e] = histcounts(tv,'BinMethod','integers');
                    [u,v] = max(N);
                     if (u>0)
                         SQ(y,ty) = (e(v)+e(v+1))/2;
                     end
                end
            end
            Fr = [Fr SQ ];
        end

        All = [All; Fr];
    end

    imwrite(All,MAP,[name '.bmp']);

end
