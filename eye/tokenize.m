function tokens = tokenize(remain)

i = 1;
while true
   [str, remain] = strtok(remain, ' ');
   if isempty(str),  break;  end
   tokens{i} = str;
   i = i + 1;
   % disp(sprintf('%s', str))
end