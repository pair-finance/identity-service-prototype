
#!/usr/bin/env puma
# frozen_string_literal: true

threads_count = ENV.fetch('PUMA_THREADS') { 5 }.to_i
threads threads_count, threads_count
port ENV.fetch('PORT') { 3000 }.to_i
workers ENV.fetch('WORKERS') { 3 }.to_i

