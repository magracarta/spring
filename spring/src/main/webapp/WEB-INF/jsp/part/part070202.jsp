<%@ page contentType="text/html;charset=utf-8" language="java" %><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 코드관리 > 엑셀자료일괄적용 > null > null
-- 작성자 : 박준영
-- 최초 작성일 : 2020-11-27 11:06:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var auiGridSample;

        $(document).ready(function () {
            createInitGrid();
			createAUIGridSample();
            fileUploadInit();
        });

        function fileUploadInit() {
            // IE10, 11은 readAsBinaryString 지원을 안함. 따라서 체크함.
            var rABS = typeof FileReader !== "undefined"
                && typeof FileReader.prototype !== "undefined"
                && typeof FileReader.prototype.readAsBinaryString !== "undefined";

            // HTML5 브라우저인지 체크 즉, FileReader 를 사용할 수 있는지 여부
            function checkHTML5Brower() {
                var isCompatible = false;
                if (window.File && window.FileReader && window.FileList
                    && window.Blob) {
                    isCompatible = true;
                }
                return isCompatible;
            }

            // 파일 선택하기
            $('#fileSelector').on('change', function (evt) {
                if (!checkHTML5Brower()) {
                    alert("브라우저가 HTML5 를 지원하지 않습니다.\r\n서버로 업로드해서 해결하십시오.");
                    return;
                } else {
                    var data = null;
                    var file = evt.target.files[0];
                    if (typeof file == "undefined") {
                        alert("파일 선택 시 오류 발생!!");
                        return;
                    }
                    var reader = new FileReader();

                    reader.onload = function (e) {
                        var data = e.target.result;

                        /* 엑셀 바이너리 읽기 */
                        var workbook;

                        if (rABS) { // 일반적인 바이너리 지원하는 경우
                            workbook = XLSX.read(data, {
                                type: 'binary'
                            });
                        } else { // IE 10, 11인 경우
                            var arr = fixdata(data);
                            workbook = XLSX.read(btoa(arr), {
                                type: 'base64'
                            });
                        }

                        var jsonObj = process_wb(workbook);
                        createAUIGrid(jsonObj[Object.keys(jsonObj)[0]]);
                    };

                    if (rABS) {
                        reader.readAsBinaryString(file);
                    } else {
                        reader.readAsArrayBuffer(file);
                    }
                }
            });
        }

        // IE10, 11는 바이너리스트링 못읽기 때문에 ArrayBuffer 처리 하기 위함.
        function fixdata(data) {
            var o = "", l = 0, w = 10240;
            for (; l < data.byteLength / w; ++l) {
                o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w, l * w + w)));
            }
            o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w)));
            return o;
        }

        // 파싱된 시트의 CDATA 제거 후 반환.
        function process_wb(wb) {
            var output = "";
            output = JSON.stringify(to_json(wb));
            output = output.replace(/<!\[CDATA\[(.*?)\]\]>/g, '$1');
            return JSON.parse(output);
        }

        // 엑셀 시트를 파싱하여 반환
        function to_json(workbook) {
            var result = {};
            workbook.SheetNames.forEach(function (sheetName) {
                // JSON 으로 파싱
                var roa = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);

                if (roa.length > 0) {
                    result[sheetName] = roa;
                }
            });
            return result;
        }

        // 저장
        function goSave() {
			var frm = $M.toValueForm(document.main_form);

			var concatCols = [];
			var concatList = [];

			var gridIds = [auiGrid];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}

			var gridFrm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridFrm, frm);

			$M.goNextPageAjaxSave(this_page + "/save", gridFrm, {method : 'POST'},
					function (result) {
						if(result.success) {
							alert("저장이 완료되었습니다.");
							window.location.reload();
						}
					}
			);
        }

        // 삭제
        function goRemove() {
			// 그리드 초기화
			AUIGrid.clearGridData(auiGrid);
			// 설정초기화
			$M.clearValue({field: ["file_name", "fileSelector"]});
			$("#total_cnt").html(0);
        }

        // 샘플 다운로드
		function fnDownload() {
			fnExportExcel(auiGridSample, "상품코드일괄적용 샘플");
		}

        function goSearchFile() {
            // openFileUploadPanel('setFileInfo', 'upload_type=PART&file_type=etc');
            $("#fileSelector").click();
        }

        function getCmaFileName(obj) {
            var fileObj, pathHeader, pathMiddle, pathEnd, allFilename, fileName, extName;
            if (obj == "[object HTMLInputElement]") {
                fileObj = obj.value
            } else {
                fileObj = document.getElementById(obj).value;
            }

            if (fileObj != "") {
                pathHeader = fileObj.lastIndexOf("\\");
                pathMiddle = fileObj.lastIndexOf(".");
                pathEnd = fileObj.length;
                fileName = fileObj.substring(pathHeader + 1, pathMiddle);
                extName = fileObj.substring(pathMiddle + 1, pathEnd);
                allFilename = fileName + "." + extName;
            } else {
                alert("파일을 선택해주세요");
                return false;
            }

            $M.setValue("file_name", allFilename);
        }

		function convertCase(element) {
			var str = JSON.stringify(element);

			str = str.replace(/\"부품번호\":/g, "\"part_no\":");
			str = str.replace(/\"부품명\":/g, "\"part_name\":");
			str = str.replace(/\"매입원가\":/g, "\"in_stock_price\":");
			str = str.replace(/\"VAT제외\":/g, "\"vat\":");
			str = str.replace(/\"NET.단가\":/g, "\"net_price\":");
			str = str.replace(/\"비고\":/g, "\"part_remark\":");
			str = str.replace(/\"적용\":/g, "\"apply\":");

			return JSON.parse(str);
		}

        function createAUIGrid(csvStr) {
			if (AUIGrid.isCreated(auiGrid)) {
				AUIGrid.destroy(auiGrid);
				auiGrid = null;
			}

			csvStr = convertCase(csvStr);
			$("#total_cnt").html(csvStr.length);

            var gridPros = {
				rowIdField: "_$uid",
				softRemovePolicy: "exceptNew",
				wrapSelectionMove: true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
				enableFilter: true,
				softRemoveRowMode: false,
            };

            var columnLayout = [
                {
                    headerText: "부품번호",
                    dataField: "part_no",
					width: "140",
					minWidth: "130",
					style : "aui-center"
                },
                {
                    headerText: "부품명",
                    dataField: "part_name",
					width: "240",
					minWidth: "230",
					style: "aui-left"
                },
                {
                    headerText: "매입원가",
                    dataField: "in_stock_price",
                    dataType: "numeric",
                    formatString: "#,##0",
					width: "100",
					minWidth: "90",
					style: "aui-right"
                },
                {
                    headerText: "VAT제외",
                    dataField: "vat",
					dataType: "numeric",
					formatString: "#,##0",
					width: "100",
					minWidth: "90",
					style: "aui-right"
                },
                {
                    headerText: "NET.단가",
                    dataField: "net_price",
					dataType: "numeric",
					formatString: "#,##0",
					width: "100",
					minWidth: "90",
					style: "aui-right"
                },
                {
                    headerText: "비고",
                    dataField: "part_remark",
					width: "240",
					minWidth: "230",
					style: "aui-left"
                },
                {
                    headerText: "적용",
					width: "100",
					minWidth: "90",
                    dataField: "apply"
                },
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, csvStr);

			$("#auiGrid").resize();
        }

        function createInitGrid() {
            var gridPros = {
                // Row번호 표시 여부
                showRowNumColum: true,
            };

            var columnLayout = [
                {
                    headerText: "부품번호",
                    dataField: "a"
                },
                {
                    headerText: "부품명",
                    dataField: "b"
                },
                {
                    headerText: "매입원가",
                    dataField: "c",
                    dataType: "numeric",
                    formatString: "#,##0"
                },
                {
                    headerText: "VAT제외",
                    dataField: "d"
                },
                {
                    headerText: "NET.단가",
                    dataField: "e"
                },
                {
                    headerText: "비고",
                    dataField: "f"
                },
                {
                    headerText: "적용",
                    dataField: "g"
                },
            ];

            // 실제로 #grid_wrap에 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, []);
        }

		function createAUIGridSample() {
			var gridPros = {
				// Row번호 표시 여부
				showRowNumColum: true,
			};

			var columnLayout = [
				{
					headerText: "부품번호",
					dataField: "part_no"
				},
				{
					headerText: "부품명",
					dataField: "part_name",
					style: "aui-left"
				},
				{
					headerText: "매입원가",
					dataField: "in_price",
					dataType: "numeric",
					formatString: "#,##0",
					style: "aui-right"
				},
				{
					headerText: "VAT제외",
					dataField: "vat",
					formatString: "#,##0",
					style: "aui-right"
				},
				{
					headerText: "NET.단가",
					dataField: "net_price",
					formatString: "#,##0",
					style: "aui-right"
				},
				{
					headerText: "비고",
					dataField: "part_remark",
					style: "aui-left"
				},
				{
					headerText: "적용",
					dataField: "apply"
				},
			];

			var sampleData = [
				{
					"part_no": "048959",
					"part_name": "ELEMENT, HYDRAULIC",
					"in_price": "10000",
					"vat": "10000",
					"net_price": "10000",
					"part_remark": "비고",
					"apply": ""
				}
			]

			// 실제로 #grid_wrap에 그리드 생성
			auiGridSample = AUIGrid.create("#auiGridSample", columnLayout, gridPros);

			// 그리드 갱신
			AUIGrid.setGridData(auiGridSample, sampleData);
		}
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <div class="contents">
                    <!-- 기본 -->
                    <div class="search-wrap mt5">
                        <table class="table table-fixed">
                            <colgroup>
                                <col width="60px">
                                <col width="250px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>엑셀파일</th>
                                <td>
                                    <div class="form-row inline-pd">
                                        <div class="input-group col-auto">
                                            <input type="text" class="form-control width180px" id="file_name" name="file_name" readonly="readonly">
                                            <input type="file" name="fileSelector" id="fileSelector" style="display:none; width:5px;" accept=".xlsx" onchange="javascript:getCmaFileName(this);">
                                            <button type="button" class="btn btn-primary-gra width140px " name="btn_excel_upload" id="btn_excel_upload" onclick="javascript:goSearchFile();">액셀업로드</button>
                                        </div>
                                    </div>
                                </td>
                                <td></td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /기본 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>엑셀적용내역</h4>
						<div class="btn-group">
							<div class="right">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 555px;"></div>
					<div id="auiGridSample" style="display:none;"></div>
                    <!-- 그리드 서머리, 컨트롤 영역 -->
                    <div class="btn-group mt5">
                        <div class="left">
                            총 <strong class="text-primary" id="total_cnt">0</strong>건
                        </div>
                        <div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>