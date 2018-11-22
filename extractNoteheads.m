function [noteheads] = extractNoteheads(sheet,template)

noteheads = imclose(sheet, template);
noteheads = noteheads < 0.95;

end

