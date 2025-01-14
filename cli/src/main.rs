use clap::{Args, Parser, Subcommand, ValueEnum};
use rustyline::error::ReadlineError;
use rustyline::{DefaultEditor, Result};

/// Command input
#[derive(Parser)]
#[command(name="nb", about = "This is Nick's personal command line interface!", long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

/// All of the possible main commands that the CLI can run
#[derive(Subcommand)]
enum Command {
    #[command(arg_required_else_help = true)]
    Project {
        #[arg(required = false)]
        name: Option<String>,

        #[command(flatten)]
        project_options: ProjectOptions,
    },
    Code {
        #[arg(required = true)]
        name: String,
    },
}

#[derive(Args)]
#[group(required = false, multiple = false)]
struct ProjectOptions {
    /// Search for a project by name
    #[arg(short, long)]
    search: bool,
    /// List all keyword pojects
    #[arg(short, long)]
    list: bool,
}

fn main() {
    println!("Starting CLI...");
    let args = Cli::parse();

    match args.command {
        // Project command
        Command::Project {
            name,
            project_options,
        } => match &name {
            None => project_list(),
            Some(name) => {
                if project_options.search {
                    project_search(&name);
                    return;
                }

                if project_options.list {
                    project_list();
                    return;
                }

                project_open(&name);
            }
        },

        // Code command
        Command::Code { name } => code_command(&name),
    }
}

/// Opens a project from the command line
fn project_open(name: &str) {
    // Check if project exists
    println!("Opening project {}", name);
}

/// Searches for a project with a given name
fn project_search(name: &str) {
    println!("Searching for project with name {}...", name);

    // Search for project
    let projects = vec!["Project 1", "Project 2", "Project 3"];

    let mut found = false;
    for project in projects.iter() {
        if project == &name {
            println!("Projects found: {}", project);
            found = true;
            break;
        }
    }

    if (found) {
        println!("Would you like to open this project? (y/n)");
        let mut rl = DefaultEditor::new();
        let readline = rl.unwrap().readline(">> ");
    } else {
        println!("Project not found. Would you like to create a new project? (y/n)");
        let mut rl = DefaultEditor::new();
        let readline = rl.unwrap().readline(">> ");
    }
}

/// Lists all project names
fn project_list() {
    println!("Listing all projects...");
    let projects = vec!["Project 1", "Project 2", "Project 3"];

    // Loop through projects with index
    for (i, project) in projects.iter().enumerate() {
        println!("{}: {}", i + 1, project);
    }

    println!("Open project by number, add to list of projects by starting with '$' or search again with by starting with '%'");

    let rl = DefaultEditor::new();
    let readline = rl.unwrap().readline(">> ");

    // Check for errors in the input
    if readline.is_err() {
        println!("Error reading input");
        return;
    }

    // Depending on the first character, add a new project to the list and open it,
    // search for a project or just open the project
    match readline.unwrap().as_str().chars().nth(0).unwrap() {
        '$' => {
            println!("Adding new project...");
        }
        '%' => {
            println!("Searching for project...");
        }
        _ => {
            println!("Opening project...");
        }
    }
}

/// Opens a code space from the command line
fn code_command(name: &str) {
    // Code command logic
    println!("Code command activated");
}

fn get_command() {
    let mut rl = DefaultEditor::new();
    let readline = rl.unwrap().readline(">> ");
}
