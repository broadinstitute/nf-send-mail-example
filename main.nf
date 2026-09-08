#!/usr/bin/env nextflow

nextflow.enable.strict = true
nextflow.enable.types = true

include { validateParameters } from 'plugin/nf-schema'

params {
    from: String
    to: String
    subject: String
    text: String
}

workflow {

    main:

    validateParameters()

    def example_ch = channel.of(
            record(
                message: """
                secrets.EMAIL_HOST: ${secrets.EMAIL_HOST ? "set" : "null"}
                secrets.EMAIL_PORT: ${secrets.EMAIL_PORT ? "set" : "null"}
                secrets.EMAIL_USER: ${secrets.EMAIL_USER ? "set" : "null"}
                secrets.EMAIL_PASSWORD: ${secrets.EMAIL_PASSWORD ? "set" : "null"}

                ${params.text}""".stripIndent()
            )
        )
        .view()

    example_ch
        .map { it -> it.message }
        .subscribe { message ->
            if (!workflow.stubRun) {
                sendMail(
                    from: params.from,
                    to: params.to,
                    subject: params.subject,
                    text: message,
                )
            }
        }

    publish:
    results = example_ch
}

output {
    results {
    }
}
