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
                secrets.EMAIL_HOST: ${{ try { secrets.EMAIL_HOST ? 'set' : 'unset' } catch (_e) { 'unset' } }()}
                secrets.EMAIL_PORT: ${{ try { secrets.EMAIL_PORT ? 'set' : 'unset' } catch (_e) { 'unset' } }()}
                secrets.EMAIL_USER: ${{ try { secrets.EMAIL_USER ? 'set' : 'unset' } catch (_e) { 'unset' } }()}
                secrets.EMAIL_PASSWORD: ${{ try { secrets.EMAIL_PASSWORD ? 'set' : 'unset' } catch (_e) { 'unset' } }()}

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
