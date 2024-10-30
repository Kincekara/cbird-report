version 1.0

workflow cbird_report {
    meta {
        description: "AMR Anlysis results report generator for C-BIRD"
    }

    input {
        File amr_report
        String date
        String labid
        String taxon
        String percent
        File logo1
        File logo2
        String? institute
        String? laboratory
        String? address
        String? clia_id
        String? phone
        String? fax
    }

    call plain_report {
        input:
            amr_report = amr_report,
            date = date,
            labid = labid,
            taxon = taxon,
            percent = percent,
            logo1 = logo1,
            logo2 = logo2,
            institute = institute,
            laboratory = laboratory,
            address = address,
            clia_id = clia_id,
            phone = phone,
            fax = fax
    }

    output {
        File clia_report = plain_report.report
    }
    }

task plain_report {
    input {
        File amr_report
        String date
        String labid
        String taxon
        String percent
        File logo1
        File logo2
        String? institute
        String? laboratory
        String? address
        String? clia_id
        String? phone
        String? fax
    }

    command <<<
        # run python script
        report.py \
        -d "~{date}" \
        -i "~{labid}" \
        -o "~{taxon}" \
        -p "~{percent}" \
        -a ~{amr_report} \
        -l ~{logo1} \
        -r ~{logo2} \
        --institute ~{institute} \
        --lab ~{laboratory} \
        --address ~{address} \
        --clia ~{clia_id} \
        --phone ~{phone} \
        --fax ~{fax}

        # rename report
        mv report.docx ~{labid}_clia_report.docx
    >>>

    output {
        File report = "~{labid}_clia_report.docx"
    }

    runtime {
        docker: "kincekara/cbird-report:0.1"
        memory: "1 GB"
        cpu: 1
        disks: "local-disk 100 SSD"
        preemptible: 0
    }


}