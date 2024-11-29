function [] = plot_all_landmarks_map(data, xmin, xmax, ymin, ymax, tag, color)
    % Plot landmarks
    xdata = [];
    ydata = [];
    count = 1;
    for i_landmark = 1:data.num_landmarks
        if data.clandmarkX(i_landmark) > xmin && data.clandmarkX(i_landmark) < xmax
           if data.clandmarkY(i_landmark) > ymin && data.clandmarkY(i_landmark) < ymax  
            xdata(count) = data.clandmarkX(i_landmark);
            ydata(count) = data.clandmarkY(i_landmark);
            count = count + 1;
           end
        end
    end
     
    scatter(xdata, ydata, tag, color);
end

