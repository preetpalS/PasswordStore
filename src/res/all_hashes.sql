SELECT h.hash, t.target, (h.valid_to IS NULL)
FROM hashes h, targets t
WHERE h.target_id = t.id;
