% This function removes "frequencies" within a radius
function [result] = filterwithfourier(photoGrayscale, fourierRadiusFilter)
    % Go to fourier space
    ft = fft2(photoGrayscale);

    % Do fourier magic
    radius = fourierRadiusFilter;
    [M, N] = size(ft);

    % Create spherical mask (create a sphere in each corner instead of
    % fftshift)
    [x,y] = meshgrid(1:N, 1:M);
    M = M+2; % index offset + pixel of sphere on other side that is already used
    N = N+2; % index offset + pixel of sphere on other side that is already used
    mask1 = ((x-0).^2 + (y-0).^2) < radius; % top left
    mask2 = ((x-N).^2 + (y-0).^2) < radius; % top right
    mask3 = ((x-0).^2 + (y-M).^2) < radius; % bottom left
    mask4 = ((x-N).^2 + (y-M).^2) < radius; % bottom right
    mask = (mask1 | mask2 | mask3 | mask4); % combine masks

    % Return to real space with mask applied
    filteredImage = ifft2(ft.*mask);
    result = 1.0-imsubtract(filteredImage, photoGrayscale);
end

