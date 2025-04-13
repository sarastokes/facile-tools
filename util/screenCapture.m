function screenCapture(opts)

    arguments
        opts.Position   (1,4)   double {mustBeInteger} = [0 0 1920 1080]
        opts.FileName   (1,1)   string = ""
        opts.Copy       (1,1)   logical = false
    end

    pause(2);

    robot = java.awt.Robot();
    rect = java.awt.Rectangle(pos(1), pos(2), pos(3), pos(4));
    cap = robot.createScreenCapture(rect);

    % Convert to an RGB image
    rgbData = typecast(cap.getRGB(0, 0, cap.getWidth, cap.getHeight,...
        [], 0, cap.getWidth), 'uint8');
    img = zeros(cap.getHeight, cap.getWidth, 3, 'uint8');
    img(:,:,1) = reshape(rgbData(3:4:end), cap.getWidth, [])';
    img(:,:,2) = reshape(rgbData(2:4:end), cap.getWidth, [])';
    img(:,:,3) = reshape(rgbData(1:4:end), cap.getWidth, [])';

    if opts.Copy
        clipboard('copy', img);
        fprintf('Copied screen capture to clipboard.\n');
    end
    if opts.FileName ~= ""
        imwrite(img, opts.FileName);
        fprintf('Saved screen capture as %s\n', opts.FileName);
    end
    if ~opts.Copy && opts.FileName ~= ""
        imshow(img);
    end