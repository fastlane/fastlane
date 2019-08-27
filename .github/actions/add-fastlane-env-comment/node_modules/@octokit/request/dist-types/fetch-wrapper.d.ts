import { endpoint } from "./types";
export default function fetchWrapper(requestOptions: ReturnType<endpoint> & {
    redirect?: string;
}): Promise<{
    status: number;
    url: string;
    headers: {
        [header: string]: string;
    };
    data: any;
}>;
