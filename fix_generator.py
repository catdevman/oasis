import re

with open('command/generate/main.go', 'r') as f:
    content = f.read()

def replace_question_marks(match):
    query = match.group(0)
    count = 1
    while '?' in query:
        query = query.replace('?', f'${count}', 1)
        count += 1
    return query

# Match anything from db.Prepare(" to ") or r.db.Query(" to ")
new_content = re.sub(r'db\.Prepare\("[^"]+"\)', replace_question_marks, content)
new_content = re.sub(r'db\.Query\("[^"]+"\)', replace_question_marks, new_content)

with open('command/generate/main.go', 'w') as f:
    f.write(new_content)
