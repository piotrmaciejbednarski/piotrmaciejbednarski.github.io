#!/bin/bash

# Function to generate English post template
generate_en_template() {
    local title="$1"
    local description="$2"
    local date="$3"
    local permalink="$4"

    cat << EOF
---
title: $title
description: $description
layout: post
lang: en
date: $date
permalink: /en/blog/$permalink/
---

Write your English content here.
EOF
}

# Function to generate Polish post template
generate_pl_template() {
    local title="$1"
    local description="$2"
    local date="$3"
    local permalink="$4"

    cat << EOF
---
title: $title
description: $description
layout: post
lang: pl
date: $date
permalink: /pl/blog/$permalink/
---

Napisz tutaj treść po polsku.
EOF
}
