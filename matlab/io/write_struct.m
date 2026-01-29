function write_struct(filename, s)
try
    txt=jsonencode(s);
catch
    txt=jsonencode(struct('note','jsonencode failed (non-serializable fields)'));
end
fid=fopen(filename,'w'); fwrite(fid, txt); fclose(fid);
end
