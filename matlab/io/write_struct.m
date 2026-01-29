function write_struct(filename, s)
% Robust JSON writer for MATLAB (handles older versions without jsonencode)
txt = '';
if exist('jsonencode','file') == 2
    try
        txt = jsonencode(s);
    catch
        txt = jsonencode(struct('note','jsonencode failed (non-serializable fields)'));
    end
else
    % Fallback: write a minimal text representation
    txt = 'jsonencode not available in this MATLAB version. Use MATLAB R2016b+ for JSON export.';
end
fid=fopen(filename,'w');
fwrite(fid, txt);
fclose(fid);
end
