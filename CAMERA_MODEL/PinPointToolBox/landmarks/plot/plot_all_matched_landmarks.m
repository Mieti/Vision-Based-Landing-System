function [] = plot_all_matched_landmarks(data, size, xmin, xmax, ymin, ymax, tag, color)
    % Plot landmarks
    xdata = [];
    ydata = [];
    count = 1;
    for i_landmark = 1:size
        if data(i_landmark*2-1) > xmin && data(i_landmark*2-1) < xmax
           if data(i_landmark*2) > ymin && data(i_landmark*2) < ymax
            xdata(count) = data(i_landmark*2-1);
            ydata(count) = data(i_landmark*2);
            count = count + 1;
           end
        end
    end
     
    scatter(xdata, ydata, tag, color);
end

