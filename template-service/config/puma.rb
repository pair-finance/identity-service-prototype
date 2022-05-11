
#!/usr/bin/env puma
# frozen_string_literal: true

threads_count = ENV.fetch('PUMA_THREADS') { 5 }.to_i
threads threads_count, threads_count
port ENV.fetch('PORT') { 3003 }.to_i
workers ENV.fetch('WORKERS') { 1 }.to_i
worker_timeout 5000
