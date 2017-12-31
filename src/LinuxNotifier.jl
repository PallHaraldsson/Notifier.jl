module LinuxNotifier

import Base.notify
export notify, register_email, email, alarm

import WAV


if is_unix() || is_linux()
    isstring(x) = typeof(x) <: AbstractString

    @doc """
    ---
    notify(message::String; title::String, sound, time)

    title = "\$(now())"\n
    sound = false\n
    time = 4 # display time (seconds)

    """ notify
    function notify(message::String;
                     title="$(now())",
                     sound=false,
                     time=4)
        if sound == true
            run(`notify-send $title $message -i $(Pkg.dir())/LinuxNotifier/src/logo.svg -t $(time * 1000)`)
            WAV.wavplay("$(Pkg.dir())/LinuxNotifier/src/LinuxNotifier_sound.wav")
        elseif isstring(sound)
            run(`notify-send $title $message -i $(Pkg.dir())/LinuxNotifier/src/logo.svg -t $(time * 1000)`)
            WAV.wavplay(sound)
        else
            run(`notify-send $title $message -i $(Pkg.dir())/LinuxNotifier/src/logo.svg -t $(time * 1000)`)
        end
    end

    @doc """
        alarm(;sound::AbstactString)
        notify by sound

    """ alarm
    alarm(;sound::AbstractString="$(Pkg.dir())/LinuxNotifier/src/LinuxNotifier_sound.wav") = WAV.wavplay(sound)


    "register a recipient e-mail address"
    function register_email()
        output_dir = "$(Pkg.dir())/LinuxNotifier/email"
        if ! ispath(output_dir); mkdir(output_dir); end

        if ispath(output_dir * "/address.txt")

            println("An e-mail address is already registered.")
            println("Do you overwrite? [y/n]")
            YesNo = lowercase(chomp(readline(STDIN)))

            if YesNo ∈ ["n", "no"]
                return
            end

            println("\nType your desired recipient e-mail address to receive a notification.")
            print("e-mail: ")
            ToAddress = chomp(readline(STDIN))
            fp = open("$output_dir/address.txt", "w")
            write(fp, ToAddress)
            close(fp)

        else
            println("Type your desired recipient e-mail address to receive a notification.")
            print("e-mail: ")
            ToAddress = chomp(readline(STDIN))
            fp = open("$output_dir/address.txt", "w")
            write(fp, ToAddress)
            close(fp)

            println("\nRecipient e-mail address is saved at $output_dir/address.txt.")
            println("If you want to change the address, modify $output_dir/address.txt directly or execute register_email() again.")

        end

    end



    """
    email(message; subject, ToAddress)

    defalut\n
    subject="\$(now())"\n
    ToAddress="not-specified"\n

    """
    function email(message; subject="$(now())", ToAddress="not-specified")
        output_dir = "$(Pkg.dir())/LinuxNotifier/email"
        if ToAddress == "not-specified"
            if ispath(output_dir * "/address.txt")
                ToAddress = readline(output_dir * "/address.txt")
            else
                println("Email address is not specified.")
                println("To send an e-mail, register an e-mail address by register_email() or")
                println("specify it by ToAddress option like")
                println("	email(\"some messages\", ToAddress=\"hoge@example.com\").")

                return
            end
        end
        run(pipeline(`echo $message`, `mail -s $subject $ToAddress`))
    end
end # if
end # module
