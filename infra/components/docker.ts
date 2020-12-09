
export class DockerfileBuilder {
	baseImage: string;
	path: string;

	constructor() {
		this.baseImage = "";
		this.path = "";
		this.files = [];
		this.prefix = "";
		this.suffix = "";

		this.steps = []


	} 
};

export class ImageBuilder extends DockerfileBuilder {
	constructor() {
        super("beast:impala:train", name, args, opts);
	}
};  
