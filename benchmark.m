t1 = tic;
x_min = -8000;
x_max = 4000;
y_min = -8000;
y_max = 4000;
counter = 1;

for i=1:100
    x = x_min + (x_max - x_min) * rand;
    y = y_min + (y_max - y_min) * rand;
    
    tic;
    camera_shot(x, y);
    index = simple_matching();
    time = toc;
    
    if index
        results(counter).index = index;
        results(counter).x = x+2000;
        results(counter).y = y+2000;
        results(counter).time = time;
        counter = counter+1;
    end

end
toc(t1);

results_table = struct2table(results);