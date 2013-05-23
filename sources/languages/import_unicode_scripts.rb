#!/usr/bin/env ruby19
#------------------------------------------------------------------------------
#
#  Taginfo source: Languages
#
#  import_unicode_scripts.rb
#
#------------------------------------------------------------------------------
#
#  Copyright (C) 2013  Jochen Topf <jochen@remote.org>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License along
#  with this program; if not, write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
#------------------------------------------------------------------------------

require 'sqlite3'

dir = ARGV[0] || '.'
db = SQLite3::Database.new(dir + '/taginfo-languages.db')

#------------------------------------------------------------------------------

property_value_alias_file = "#{dir}/PropertyValueAliases.txt"
codepoint_script_mapping_file = "#{dir}/Scripts.txt"

db.transaction do |db|
    open(property_value_alias_file) do |file|
        file.each do |line|
            line.chomp!
            if line.match(%r{^sc ;})
                (sc, script, name) = line.split(%r{\s*;\s*})
                db.execute("INSERT INTO unicode_scripts (script, name) VALUES (?, ?)", script, name)
            end
        end
    end

    open(codepoint_script_mapping_file) do |file|
        file.each do |line|
            line.chomp!
            line.sub!(%r{\s*#.*}, '')
            next if line.match(%r{^$})
            (codes, script) = line.split(%r{\s+;\s+})
            if codes.match(%r{^[0-9A-F]{4,5}$})
                from = codes
                to   = codes
            elsif codes.match(%r{^([0-9A-F]{4,5})..([0-9A-F]{4,5})$})
                from = $1
                to   = $2
            else
                puts "Line does not match: #{line}"
                next
            end
            db.execute("INSERT INTO unicode_codepoint_script_mapping (codepoint_from, codepoint_to, name) VALUES (?, ?, ?)", from, to, script)
        end
    end
end


#-- THE END -------------------------------------------------------------------
