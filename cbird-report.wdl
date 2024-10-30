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
        # short taxon
        organism=$(echo "~{taxon}" | cut -d " " -f1,2)

        # Enterobacter cloacae complex
        ecc=("Enterobacter cloacae" "Enterobacter hormaechei" "Enterobacter sichuanensis"
        "Enterobacter asburiae" "Enterobacter cancerogenus" "Enterobacter chengduensis"
        "Enterobacter kobei" "Enterobacter ludwigii" "Enterobacter roggenkampii")

        for i in "${ecc[@]}"; do
            if [[ "$organism" == "$i" ]]; then
                report_organism="Enterobacter cloacae complex"
                break
            fi
        done
        
        # Klebsiella oxytoca complex
        koc=("Klebsiella oxytoca" "Klebsiella michiganensis" "Klebsiella grimontii" "Klebsiella huaxiensis"
        "Klebsiella huaxiensis" "Klebsiella pasteurii" "Klebsiella spallanzanii")

        for i in "${koc[@]}"; do
            if [[ "$organism" == "$i" ]]; then
                report_organism="Klebsiella oxytoca complex"
                break
            fi
        done

        # run python script
        report.py \
        -d "~{date}" \
        -i "~{labid}" \
        -o "$report_organism" \
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