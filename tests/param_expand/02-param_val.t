#!/bin/bash
# THIS FILE IS PART OF THE CYLC SUITE ENGINE.
# Copyright (C) 2008-2017 NIWA
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Check tasks and graph generated by parameter expansion.

. "$(dirname "$0")/test_header"
set_test_number 21 

#------------------------------------------------------------------------------
cat >'suite.rc' <<'__SUITE__'
[cylc]
    [[parameters]]
        i = cat, dog, fish
        j = 1..5
[scheduling]
    [[dependencies]]
        graph = """foo => bar<i,j>
                   bar<i=cat,j=3> => boo"""
[runtime]
    [[root]]
        script = true
    [[FAM<i,j>]]
    [[bar<i,j>]]
        inherit = "FAM<i,j>"
    [[bar<i=cat,j=3>]]
        inherit = "FAM<i,j>"  # implicit values here (takes i=cat,j=3)
__SUITE__

TNAME=${TEST_NAME_BASE}-1
# validate
run_ok "${TNAME}" cylc validate "suite.rc"
# family graph
graph_suite "suite.rc" "${TNAME}-graph-fam"
cmp_ok "${TNAME}-graph-fam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-fam-1.ref"
# task graph
graph_suite "suite.rc" "${TNAME}-graph-exp" -u
cmp_ok "${TNAME}-graph-exp" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-exp-1.ref"
# inheritance graph
graph_suite "suite.rc" "${TNAME}-graph-nam" -n
cmp_ok "${TNAME}-graph-nam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-nam-1.ref"

#------------------------------------------------------------------------------
cat >'suite.rc' <<'__SUITE__'
[cylc]
    [[parameters]]
        i = cat, dog, fish
        j = 1..5
[scheduling]
    [[dependencies]]
        graph = """foo => bar<i,j>
                   bar<i=cat,j=3> => boo"""
[runtime]
    [[root]]
        script = true
    [[FAM<i,j>]]
    [[bar<i,j>]]
        inherit = "FAM<i,j>"
    [[bar<i=cat,j=3>]]
        inherit = "FAM<i=cat,j=3>"  # same with explicit values
__SUITE__

TNAME=${TEST_NAME_BASE}-2
# validate
run_ok "${TNAME}" cylc validate "suite.rc"
# family graph
graph_suite "suite.rc" "${TNAME}-graph-fam"
cmp_ok "${TNAME}-graph-fam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-fam-1.ref"
# task graph
graph_suite "suite.rc" "${TNAME}-graph-exp" -u
cmp_ok "${TNAME}-graph-exp" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-exp-1.ref"
# inheritance graph
graph_suite "suite.rc" "${TNAME}-graph-nam" -n
cmp_ok "${TNAME}-graph-nam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-nam-1.ref"

#------------------------------------------------------------------------------
# Same, with white space in the parameter syntax.
cat >'suite.rc' <<'__SUITE__'
[cylc]
    [[parameters]]
        i = cat, dog, fish
        j = 1..5
[scheduling]
    [[dependencies]]
        graph = """foo => bar< i ,j >
                   bar< i = cat , j = 3 > => boo"""
[runtime]
    [[root]]
        script = true
    [[FAM<i,j>]]
    [[bar<i,j>]]
        inherit = "FAM< i, j>"
    [[bar<i=cat,j=3>]]
        inherit = "FAM<i = cat ,j=3>"
__SUITE__

TNAME=${TEST_NAME_BASE}-3
# validate
run_ok "${TNAME}" cylc validate "suite.rc"
# family graph
graph_suite "suite.rc" "${TNAME}-graph-fam"
cmp_ok "${TNAME}-graph-fam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-fam-1.ref"
# task graph
graph_suite "suite.rc" "${TNAME}-graph-exp" -u
cmp_ok "${TNAME}-graph-exp" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-exp-1.ref"
# inheritance graph
graph_suite "suite.rc" "${TNAME}-graph-nam" -n
cmp_ok "${TNAME}-graph-nam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-nam-1.ref"

#------------------------------------------------------------------------------
cat >'suite.rc' <<'__SUITE__'
[cylc]
    [[parameters]]
        i = cat, dog, fish
        j = 1..5
[scheduling]
    [[dependencies]]
        graph = """foo => bar<i,j>
                   bar<i=cat,j=3> => boo"""
[runtime]
    [[root]]
        script = true
    [[FAM<i,j>]]
    [[bar<i,j>]]
        inherit = "FAM<i,j>"
    [[bar<i=cat,j=3>]]
        inherit = "FAM<i=dog,j=1>"  # different explicit values are legal
__SUITE__

TNAME=${TEST_NAME_BASE}-4
# validate
run_ok "${TNAME}" cylc validate "suite.rc"
# family graph
graph_suite "suite.rc" "${TNAME}-graph-fam"
cmp_ok "${TNAME}-graph-fam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-fam-b.ref"
# task graph
graph_suite "suite.rc" "${TNAME}-graph-exp" -u
cmp_ok "${TNAME}-graph-exp" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-exp-b.ref"
# inheritance graph
graph_suite "suite.rc" "${TNAME}-graph-nam" -n
cmp_ok "${TNAME}-graph-nam" "${TEST_SOURCE_DIR}/${TEST_NAME_BASE}/graph-nam-b.ref"

#------------------------------------------------------------------------------
cat >'suite.rc' <<'__SUITE__'
[cylc]
    [[parameters]]
        i = cat, dog, fish
        j = 1..5
[scheduling]
    [[dependencies]]
        graph = """foo => bar<i,j>
                   bar<i=cat,j=3> => boo"""
[runtime]
    [[root]]
        script = true
    [[FAM<i,j>]]
    [[bar<i,j>]]
        inherit = "FAM<i,j>"
    [[bar<i=cat,j=3>]]
        inherit = "FAM<i=dog,j=1>"
    [[boo]]
        inherit = "FAM<i=dog,j=1>"  # OK (plain task can inherit from specific params)
__SUITE__

run_ok "${TEST_NAME_BASE}-5" cylc validate "suite.rc"

#------------------------------------------------------------------------------
cat >'suite.rc' <<'__SUITE__'
[cylc]
    [[parameters]]
        i = cat, dog, fish
        j = 1..5
[scheduling]
    [[dependencies]]
        graph = """foo => bar<i,j>
                   bar<i=cat,j=3> => boo"""
[runtime]
    [[root]]
        script = true
    [[FAM<i,j>]]
    [[bar<i,j>]]
        inherit = "FAM<i=frog,j>"  # ERROR: no frog
    [[bar<i=cat,j=3>]]
        inherit = "FAM<i=dog,j=1>"
__SUITE__

TNAME=${TEST_NAME_BASE}-err-1
run_fail "${TNAME}" cylc validate "suite.rc"
cmp_ok "${TNAME}.stderr" - << __ERR__
ERROR, illegal value 'i=frog' in 'inherit = FAM<i=frog,j>'
__ERR__

#------------------------------------------------------------------------------
cat >'suite.rc' <<'__SUITE__'
[cylc]
    [[parameters]]
        i = cat, dog, fish
        j = 1..5
[scheduling]
    [[dependencies]]
        graph = """foo => bar<i,j>
                   bar<i=cat,j=3> => boo"""
[runtime]
    [[root]]
        script = true
    [[FAM<i,j>]]
    [[bar<i,j>]]
        inherit = "FAM<i,j>"
    [[bar<i=cat,j=3>]]
        inherit = "FAM<i=dog,j=1>"
    [[boo]]
        inherit = "FAM<i,j=1>"  # ERROR: i undefined here.
__SUITE__

TNAME="${TEST_NAME_BASE}-err-2"
run_fail "${TNAME}" cylc validate "suite.rc"
cmp_ok "${TNAME}.stderr" - << __ERR__
ERROR, parameter 'i' undefined in 'inherit = FAM<i,j=1>'
__ERR__