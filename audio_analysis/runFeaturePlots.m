function runFeaturePlots(diem)

if(nargin < 1)
    diem = 'diem1';
end

figure_scripts_directory = ['/Users/pkmital/diem/matlab/figure'];
mir_toolbox_directory = ['/Users/pkmital/Coding/Matlab/MIRtoolbox1.3.3'];
audio_directory = ['/Users/pkmital/diem/data/DIEM/Experiments/deploy/' diem '/library/audio'];
output_directory = ['output'];

mkdir(output_directory);

addpath(genpath(figure_scripts_directory));
addpath(genpath(mir_toolbox_directory));
files = dir([audio_directory '/*.wav']);
seconds_per_tick = 10; % not actually seconds per tick yet

bool_perform = [ones(50,1)];
frame_size = 0.0929;            % 4096 samples @ 44100 Hz
hop_size = 0.25;                % 1024

dpi = 300;

for file_i = 1 : length(files)
    
    audiofeatures = ...
    struct( 'signal', [], ...
            'spectrum', [], ...
            'centroid', [], ...
            'brightness', [], ...
            'roughness', [], ...
            'kurtosis', [], ...
            'spread', [], ...
            'skewness', [], ...
            'flatness', [], ...
            'rolloff85', [], ...
            'entropy', [], ...
            'regularity', [], ...
            'envelope', [], ...
            'spectralflux', [], ...
            'rms', [], ...
            'zcr', [], ...
            'novelty', []); 
        
    %% Plot the Signal
    h=formatFigure(1);
    [sound_file sr] = wavread([audio_directory '/' files(file_i).name]);
    
    cla,
    plot(sound_file),
    file_name = strrep(files(file_i).name(1:end-4), '_', ' ');
    
    axis tight
    set(gca, 'FontSize', 12)
    set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
    title([{file_name, 'Signal'}], 'FontWeight', 'bold', 'FontSize', 14)
    
    set(gca, 'XTick', 1 : sr * seconds_per_tick : length(sound_file));
    set(gca, 'XTickLabel', [0 : floor(length(sound_file) / sr)] .* seconds_per_tick);
    
    xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
    ylabel('Amplitude', 'FontWeight', 'bold', 'FontSize', 14);
    ylim([-1.0 1.0]),
    %print('-f1','-r600','-djpeg',[output_directory '/' files(file_i).name(1:end-4)]);
    print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_signal.pdf']);
    
    audiofeatures.signal = sound_file;
    
    %% Plot the Spectrum
    h=formatFigure(2);
    mir_file = miraudio([audio_directory '/' files(file_i).name]);
    
    % 0.0929 * 44100 = frame size of 4096, 0.5 = hop of 2048
    mir_spec = mirspectrum(mir_file, 'Frame', frame_size, hop_size, 'Max', 3000);    
    mir_spec_data = mirgetdata(mir_spec);
    
    imagesc(mir_spec_data);
    axis tight
    set(gca,'YDir','normal')
    set(gca, 'FontSize', 12)
    set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
    title([{file_name, 'Spectrum'}], 'FontWeight', 'bold', 'FontSize', 14)
    
    % took some hacing to figure out what the hell this data structure is
    fp = get(mir_spec, 'FramePos');
    xx = fp{1}{1}(1,:);
    p = get(mir_spec, 'Pos');
    pp = p{1}{1};
    
    % but it eventually gives you the seconds in FramePos
    %set(gca, 'XTick', 1 : size(pp,2) / seconds_per_tick : size(pp,2));
    %set(gca, 'XTickLabel', floor(1 : fp{1}{1}(1,end) / seconds_per_tick : fp{1}{1}(1,end)));
    xt = get(gca,'XTick');
    seconds = xx(xt(1:end-1)+1);
    seconds(1,end+1) = seconds(1,end)+seconds(1,2);
    seconds = floor(seconds);
    set(gca, 'XTickLabel', seconds);
    
    % and the frequency bins in Pos
    set(gca, 'YTick', 1 : size(pp(:,1)) / seconds_per_tick : size(pp(:,1)));
    set(gca, 'YTickLabel', floor(pp(1 : size(pp(:,1)) / seconds_per_tick : size(pp(:,1)),1)));
    
    xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
    ylabel('Frequency (Hz)', 'FontWeight', 'bold', 'FontSize', 14);
    
    print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_spectrum.pdf']);
    
    audiofeatures.spectrum = mir_spec_data;
    
    %% Plot the Centroid
    if(bool_perform(3))

        h=formatFigure(3);

        mir_centroid = mircentroid(mir_spec);
        mir_centroid_data = mirgetdata(mir_centroid);

        plot(mir_centroid_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Centroid'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_centroid.pdf']);
        
        audiofeatures.centroid = mir_centroid_data;
    end
    
    
    %% Plot the Brightness
    if(bool_perform(4))
        
        h=formatFigure(4);

        mir_brightness = mirbrightness(mir_spec);
        mir_brightness_data = mirgetdata(mir_brightness);

        plot(mir_brightness_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Brightness'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_brightness.pdf']);
        
        audiofeatures.brightness = mir_brightness_data;
    end
    %% Plot the Roughness
    if(bool_perform(5))
        
        h=formatFigure(5);

        mir_roughness = mirroughness(mir_spec);
        mir_roughness_data = mirgetdata(mir_roughness);

        plot(mir_roughness_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Roughness'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_roughness.pdf']);
        
        audiofeatures.roughness = mir_roughness_data;
    end
    
    %% Plot the Kurtosis
    if(bool_perform(6))

        h=formatFigure(6);

        mir_kurtosis = mirkurtosis(mir_spec);
        mir_kurtosis_data = mirgetdata(mir_kurtosis);

        plot(mir_kurtosis_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Kurtosis'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_kurtosis.pdf']);
        
        audiofeatures.kurtosis = mir_kurtosis_data;
    end
    %% Plot the Spread
    if(bool_perform(7))
        
        h=formatFigure(7);

        mir_spread = mirspread(mir_spec);
        mir_spread_data = mirgetdata(mir_spread);

        plot(mir_spread_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Spread'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_spread.pdf']);
        
        audiofeatures.spread = mir_spread_data;
    end
    
    %% Plot the Skewness
    if(bool_perform(8))

        h=formatFigure(8);

        mir_skewness = mirskewness(mir_spec);
        mir_skewness_data = mirgetdata(mir_skewness);

        plot(mir_skewness_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Skewness'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_skewness.pdf']);
        
        audiofeatures.skewness = mir_skewness_data;
    end
    
    %% Plot the Flatness
    if(bool_perform(9))
        
        h=formatFigure(9);

        mir_flatness = mirflatness(mir_spec);
        mir_flatness_data = mirgetdata(mir_flatness);

        plot(mir_flatness_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Flatness'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_flatness.pdf']);
        
        audiofeatures.flatness = mir_flatness_data;
    end
    
    %% Plot the Roll-off
    if(bool_perform(10))
        
        h=formatFigure(10);

        mir_rolloff = mirrolloff(mir_spec);
        mir_rolloff_data = mirgetdata(mir_rolloff);

        plot(mir_rolloff_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Rolloff'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_rolloff.pdf']);
        
        audiofeatures.rolloff85 = mir_rolloff_data;
    end
    
    %% Plot the Entropy
    if(bool_perform(11))
        
        h=formatFigure(11);

        mir_entropy= mirentropy(mir_spec);
        mir_entropy_data = mirgetdata(mir_entropy);

        plot(mir_entropy_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Entropy'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_entropy.pdf']);
        
        audiofeatures.entropy = mir_entropy_data;
    end
    
    %% Plot the Regularity
    if(bool_perform(12))
        h=formatFigure(12);

        mir_regularity= mirregularity(mir_spec);
        mir_regularity_data = mirgetdata(mir_regularity);

        plot(mir_regularity_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Regularity'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_regularity.pdf']);
        
        
        audiofeatures.regularity = mir_regularity_data;
    end
    %% Plot the Envelope
    if(bool_perform(13))
        
        h=formatFigure(13);

        mir_envelope= mirenvelope(mir_file);
        mir_envelope_data = mirgetdata(mir_envelope);

        plot(mir_envelope_data, 'b');

        xt = get(gca,'XTick');
        p = get(mir_envelope, 'Pos');
        s = p{1}{1}(:,1);
        seconds = s(xt(1:end-1)+1)';
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Envelope'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 0.5]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_envelope.pdf']);
        
        audiofeatures.envelope = mir_envelope_data;
    end
    %% Plot the Spectral Flux
    if(bool_perform(14))

        h=formatFigure(14);

        mir_flux= mirflux(mir_spec);
        mir_flux_data = mirgetdata(mir_flux);

        plot(mir_flux_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Flux'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_flux.pdf']);
        
        audiofeatures.spectralflux = mir_flux_data;
    end
    
    %% Plot the RMS
    if(bool_perform(15))
        
        h=formatFigure(15);

        mir_rms = mirrms(mir_spec);
        mir_rms_data = mirgetdata(mir_rms);

        plot(mir_rms_data, 'b');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: RMS'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 0.3]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_rms.pdf']);
        
        audiofeatures.rms = mir_rms_data;
    end
    
    %% Plot the Zero Crossing Rate
    if(bool_perform(16))

        h=formatFigure(16);

        mir_zerocross= mirzerocross(mir_file,'Frame', frame_size, hop_size);
        mir_zerocross_data = mirgetdata(mir_zerocross);

        plot(mir_zerocross_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Zero-Crossing Rate'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        %ylim([0 0.3]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_zerocross.pdf']);
        
        audiofeatures.zcr = mir_zerocross_data;
    end
    %% Plot the Novelty Detection
    if(bool_perform(17))

        h=formatFigure(17);

        mir_simatrix = mirsimatrix(mir_spec);
        mir_novelty = mirnovelty(mir_simatrix);
        mir_novelty_data = mirgetdata(mir_novelty);

        plot(mir_novelty_data, 'b-+');

        xt = get(gca,'XTick');
        seconds = xx(xt(1:end-1)+1);
        seconds(1,end+1) = seconds(1,end)+seconds(1,2);
        seconds = floor(seconds);
        set(gca, 'XTickLabel', seconds);
        set(gca,'YDir','normal')
        set(gca, 'FontSize', 12)
        set(gca, 'FontWeight', 'bold', 'FontSize', 14), 
        title([{file_name, 'Feature: Novelty Detection'}], 'FontWeight', 'bold', 'FontSize', 14)

        xlabel({'Time', '(Seconds)'}, 'FontWeight', 'bold', 'FontSize', 14);
        ylabel('Coefficient Value', 'FontWeight', 'bold', 'FontSize', 14);
        ylim([0 1.0]),

        print(h,'-dpdf',sprintf('-r%d',dpi),[output_directory '/' files(file_i).name(1:end-4), '_novelty.pdf']);
        
        audiofeatures.novelty = mir_novelty_data;
    end
    
    save(['audio_features_' diem '_movie', num2str(file_i)], 'audiofeatures');
end