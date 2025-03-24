<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS집계표 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-09-01 09:54:18
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGrid;
        var dateList;
        $(document).ready(function () {
            fnInit();
            createAUIGrid();

            goSearch();
        });

        function fnInit() {
            dateList = ${dateList};

            var msMakerCd = "${defaultMakerCd}";
            var msMakerCdArr = msMakerCd.split("#");

            $('#s_maker_cd').combogrid("setValues", msMakerCdArr);
        }

        function goSearch() {
            if ($M.getValue("s_maker_cd") == "") {
                alert("메이커는 최소 1개 이상 선택해야 합니다.");
                return;
            }

            var sMakerCd = $M.getValue("s_maker_cd").split("#");
            var makerCdArr = [];
            for(var i=0; i<sMakerCd.length; i++) {
                if(makerCdArr.indexOf(sMakerCd[i]) === -1) {
                    makerCdArr.push(sMakerCd[i]);
                }
            }

            if (makerCdArr.length > 9) {
                alert("메이커는 최대 9개까지 선택 가능합니다.\n현재 " + makerCdArr.length + "개 선택하셨습니다.");
                return;
            }

            if($M.getValue("s_start_year") != $M.getValue("s_end_year")) {
            	$M.setValue("s_start_year", $M.getValue("s_end_year"));
            	$M.setValue("s_start_mon", $M.getValue("s_end_mon"));
//                 alert("조회년도는 같아야합니다.");
//                 $M.setValue("s_end_year", $M.getValue("s_start_year"));
//                 return;
            }

            if($M.toNum($M.getValue("s_start_mon")) > $M.toNum($M.getValue("s_end_mon"))) {
                alert("시작 조회월이 종료 조회월보다 늦을 수 없습니다.");
                return;
            }

            var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
            var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

            var params = {
                "s_start_dt": startDt,
                "s_end_dt": endDt,
                "s_maker_cd_str": $M.getArrStr(makerCdArr),
                "s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd")

            };

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: "GET"},
                function (result) {
                    if (result.success) {
                        destroyGrid();
                        dateList = result.dateList;
                        createAUIGrid();
                        AUIGrid.setGridData(auiGrid, result.list);

//                         var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
//                         // 구해진 칼럼 사이즈를 적용 시킴.
//                         AUIGrid.setColumnSizeList(auiGrid, colSizeList);
                    }
                }
            );
        }

        // 엑셀 다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "MS집계표");
        }

        // 그리드 초기화
        function destroyGrid() {
            AUIGrid.destroy("#auiGrid");
            auiGrid = null;
        };

        function fnSetDate(year, mon) {
            if(mon.length == 1) {
                mon = "0" + mon;
            }
            var sYearMon = year + mon;

            return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
        }

        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: false,
                // 고정칼럼 카운트 지정
                // fixedColumnCount : 6,
                enableCellMerge: true,
                cellMergeRowSpan: true,
                rowSelectionWithMerge: true,
                enableSummaryMerge: true,
                summaryMergePolicy: "all",
                headerHeight : 40,
                // [15324] 틀 고정
                fixedColumnCount : 3,
                // [23426] 총계 틀 고정
                fixedRowCount : 1,
                // 그리드 ROW 스타일 함수 정의
                rowStyleFunction: function (rowIndex, item) {
                    if (item.center_org_name.indexOf("Total") != -1 || item.center_org_name.indexOf("전체총계") != -1) {
                        return "aui-grid-row-depth3-style";
                    } else if (item.center_org_name.indexOf("[") != -1) {
                        return "aui-ms-col-style";
                    }

                    return null;
                },
            };

            var columnLayout = [
                {
                    headerText: "센터",
                    dataField: "center_org_name",
					width : "120",
					minWidth : "20",
                    cellMerge: true,
                    cellColMerge : true, // 셀 가로 병합 실행
                    cellColSpan : 3, // 셀 가로 병합 대상은 2개로 설정
                    style: "aui-center"
                },
                {
                    headerText: "센터<br/>담당자",
                    dataField: "sale_mem_name",
                    cellMerge: true, // 셀 세로 병합 실행
					width : "55",
					minWidth : "20",
                    style: "aui-center",
                },
                {
                    headerText: "메이커",
                    dataField: "maker_name",
					width : "110",
					minWidth : "20",
                    style: "aui-center",
                },
                {
                    headerText: "센터코드",
                    dataField: "center_org_code",
                    visible: false
                },
                {
                    headerText: "센터담당자 코드",
                    dataField: "sale_mem_no",
                    visible: false
                },
                {
                    headerText: "메이커코드",
                    dataField: "maker_cd",
                    visible: false
                },
                {
                    headerText: "마케팅구역코드",
                    dataField: "sale_area_code",
                    visible: false
                },
                {
                    headerText : "규격코드",
                    dataField : "ms_machine_sub_type_cd",
                    visible : false
                },
                {
                    headerText : "규격",
                    dataField : "ms_machine_sub_type_name",
                    visible : false
                },
            ];
            
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            var columnObjArr = []; // 생성할 컬럼 배열
            // 선택한 년도의 2년, 1년 전 Total
            for (var i = 2; i > 0; i--) {
                var tempYear = $M.dateFormat($M.addYears($M.toDate(dateList[0].year_mon), -i), 'yyyy');
                var headerStr = tempYear + "년 Total";
                var qtyFiledStr = "a_" + tempYear + "_tot_qty";
                var rateFiledStr = "a_" + tempYear + "_tot_rate";
                var columnObj = {
                    headerText: headerStr,
                    children: [
                        {
                            headerText: "등록<br>대수",
                            dataField: qtyFiledStr,
                            width: "4.5%",
                            styleFunction: myStyleFunction,
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return value == "0"? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "MS",
                            dataField: rateFiledStr,
                            postfix: "%",
                            width: "5%",
                            style: "aui-center",
                            // [14512] 비율항목에 막대그래프 표시 - 김경빈
                            renderer : {
                                type : "BarRenderer",
                                min : 0,
                                max : 100
                            },
                        }
                    ]
                };

                columnObjArr.push(columnObj);
            }

            // 1년전 Data
            for(var i=0; i<dateList.length; i++) {
                var beforeYear = $M.dateFormat($M.addYears($M.toDate(dateList[i].year_mon), -1), 'yyyyMM');
                var headerStr = beforeYear.substring(2, 4) + "년 " + beforeYear.substring(4) + "월";
                var qtyFiledStr = "a_" + beforeYear + "_qty";
                var rateFiledStr = "a_" + beforeYear + "_rate";
                var columnObj = {
                    headerText: headerStr,
                    children: [
                        {
                            headerText: "등록<br>대수",
                            dataField: qtyFiledStr,
                            width: "4.5%",
                            styleFunction: myStyleFunction,
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return value == "0"? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "MS",
                            dataField: rateFiledStr,
                            postfix: "%",
                            width: "5%",
                            style: "aui-center",
                            // [14512] 비율항목에 막대그래프 표시 - 김경빈
                            renderer : {
                                type : "BarRenderer",
                                min : 0,
                                max : 100
                            },
                        }
                    ]
                };

                columnObjArr.push(columnObj);

                // 동 3개월
                if(i == (dateList.length-1)) {
                    headerStr = beforeYear.substring(2, 4) + "년 동 " + dateList.length + "개월";
                    qtyFiledStr = "a_" + beforeYear.substring(0, 4) + "_" + dateList.length + "_qty";
                    rateFiledStr = "a_" + beforeYear.substring(0, 4) + "_" + dateList.length + "_rate";

                    var columnObj = {
                        headerText: headerStr,
                        children: [
                            {
                                headerText: "등록<br>대수",
                                dataField: qtyFiledStr,
                                width: "4.5%",
                                styleFunction: myStyleFunction,
                                labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                    return value == "0"? "" : $M.setComma(value);
                                }
                            },
                            {
                                headerText: "MS",
                                dataField: rateFiledStr,
                                postfix: "%",
                                width: "5%",
                                style: "aui-center",
                                // [14512] 비율항목에 막대그래프 표시 - 김경빈
                                renderer : {
                                    type : "BarRenderer",
                                    min : 0,
                                    max : 100
                                },
                            }
                        ]
                    };

                    columnObjArr.push(columnObj);
                }
            }

            var currColumnObj = {
                headerText: dateList[0].year_mon.substring(0, 4) + "년 Total",
                children: [
                    {
                        headerText: "등록<br>대수",
                        dataField: "a_" + dateList[0].year_mon.substring(0, 4) + "_tot_qty",
                        width: "4.5%",
                        styleFunction: myStyleFunction,
                        labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                            return value == "0"? "" : $M.setComma(value);
                        }
                    },
                    {
                        headerText: "MS",
                        dataField: "a_" + dateList[0].year_mon.substring(0, 4) + "_tot_rate",
                        postfix: "%",
                        width: "5%",
                        style: "aui-center",
                        // [14512] 비율항목에 막대그래프 표시 - 김경빈
                        renderer : {
                            type : "BarRenderer",
                            min : 0,
                            max : 100
                        },
                    }
                ]
            };

            columnObjArr.push(currColumnObj);

            // 현재 Data
            for(var i=0; i<dateList.length; i++) {
                var cuurYearMon = dateList[i].year_mon;
                var headerStr = cuurYearMon.substring(2, 4) + "년 " + cuurYearMon.substring(4) + "월";
                var qtyFiledStr = "a_" + cuurYearMon + "_qty";
                var rateFiledStr = "a_" + cuurYearMon + "_rate";
                var columnObj = {
                    headerText: headerStr,
                    children: [
                        {
                            headerText: "등록<br>대수",
                            dataField: qtyFiledStr,
                            width: "4.5%",
                            styleFunction: myStyleFunction,
                            labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                return value == "0"? "" : $M.setComma(value);
                            }
                        },
                        {
                            headerText: "MS",
                            dataField: rateFiledStr,
                            postfix: "%",
                            width: "5%",
                            style: "aui-center",
                            // [14512] 비율항목에 막대그래프 표시 - 김경빈
                            renderer : {
                                type : "BarRenderer",
                                min : 0,
                                max : 100
                            },
                        }
                    ]
                };

                columnObjArr.push(columnObj);

                // 동 3개월
                if(i == (dateList.length-1)) {
                    headerStr = cuurYearMon.substring(2, 4) + "년 동 " + dateList.length + "개월";
                    qtyFiledStr = "a_" + cuurYearMon.substring(0, 4) + "_" + dateList.length + "_qty";
                    rateFiledStr = "a_" + cuurYearMon.substring(0, 4) + "_" + dateList.length + "_rate";

                    var columnObj = {
                        headerText: headerStr,
                        children: [
                            {
                                headerText: "등록<br>대수",
                                dataField: qtyFiledStr,
                                width: "4.5%",
                                styleFunction: myStyleFunction,
                                labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                                    return value == "0"? "" : $M.setComma(value);
                                }
                            },
                            {
                                headerText: "MS",
                                dataField: rateFiledStr,
                                postfix: "%",
                                width: "5%",
                                style: "aui-center",
                                // [14512] 비율항목에 막대그래프 표시 - 김경빈
                                renderer: {
                                    type : "BarRenderer",
                                    min : 0,
                                    max : 100
                                },
                            }
                        ]
                    };

                    columnObjArr.push(columnObj);
                }
            }

            // 종합정보
            var columnObj = [
                {
                    headerText: "동" + dateList.length + "개월<br/> 비교장비<br/> 등록대수",
                    dataField : "a_compare_qty",
                    width: "6%",
                },
                {
                    headerText: "동" + dateList.length + "개월<br/> 비교장비<br/> 등록%",
                    dataField : "a_compare_rate",
                    width: "6%",
                },
                {
                    headerText : $M.dateFormat($M.addYears($M.toDate(dateList[0].year_mon), -1), 'yyyy').substring(2) + "년 총<br/> 대수 대비<br/> 최근" + dateList.length + "개월 %",
                    dataField : "a_recent_rate",
                    width: "8%",
                },
                {
                    headerText : $M.dateFormat($M.toDate(dateList[0].year_mon), 'yyyy').substring(2) + "년 총 대수<br/> - "
                        + $M.dateFormat($M.addYears($M.toDate(dateList[0].year_mon), -1), 'yyyy').substring(2) + "년 총 대수",
                    dataField : "a_diff_qty",
                    width: "8%",
                }
            ];
            columnObjArr = columnObjArr.concat(columnObj);

            // 컬럼 추가.
            AUIGrid.addColumn(auiGrid, columnObjArr, 'last');
            
            console.log("columnObjArr : ", columnObjArr);

//             var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
//             // 구해진 칼럼 사이즈를 적용 시킴.
//             AUIGrid.setColumnSizeList(auiGrid, colSizeList);
            $("#auiGrid").resize();

            // [14512] 숫자 데이터 클릭 시 'MS리스트' 팝업 호출 - 김경빈
            AUIGrid.bind(auiGrid, "cellClick", function(event) {

                var centerOrgName = event.item.center_org_name;
                if (centerOrgName.indexOf("전체총계") === -1 && event.value !== "" && event.headerText.indexOf("등록<br>대수") >= 0 ) {

                    var centerOrgCode = event.item.center_org_code;
                    var makerCd = event.item.maker_cd;

                    var msMon = event.dataField.replace("a_", "").replace("_qty", "");
                    // ~년 동 ~개월 - 시작연월, 끝연월 필요
                    if (msMon.indexOf("tot") === -1 && msMon.indexOf("_") !== -1) {
                        var startDt;
                        var endDt;
                        // 작년 동 ~개월일 때
                        if ($M.getValue("s_start_year") !== msMon.split("_")[0]) {
                            startDt = ($M.getValue("s_start_year") - 1) + $M.getValue("s_start_mon");
                            endDt = ($M.getValue("s_end_year") - 1) + $M.getValue("s_end_mon");
                        } else {
                            startDt = $M.getValue("s_start_year") + $M.getValue("s_start_mon");
                            endDt = $M.getValue("s_end_year") + $M.getValue("s_end_mon");
                        }
                        msMon = startDt + "#" + endDt;
                    }

                    var params = {
                        "s_area_code_str" : "total",
                        "s_sub_type_cd" : $M.getValue("s_ms_machine_type_cd"), // 장비기종코드
                        "s_ms_mon" : msMon,
                        "s_menu_type" : "total",
                        "s_center_org_code" : centerOrgCode,
                        "s_sale_mem_no" : event.item.sale_mem_no,
                    };

                    // ~센터 Total
                    if (centerOrgName.indexOf("Total") !== -1) {
                        params.s_sale_mem_no = "total";
                        // 바로 위 행의 센터코드를 파라미터로 삽입
                        params.s_center_org_code = AUIGrid.getItemByRowIndex(auiGrid, event.rowIndex - 1).center_org_code;
                        // 모든 메이커
                        params.s_select_type = "total";
                        params.s_maker_cd_str = $M.getValue("s_maker_cd");
                    } else if (centerOrgName.indexOf("소계 ]") !== -1) {
                        params.s_sale_mem_no = "total";
                        params.s_center_org_code = "total";
                    }

                    // 메이커 : 기타
                    if (makerCd === "46") {
                        params.s_select_type = "etc";
                        params.s_maker_cd_str = $M.getValue("s_maker_cd");
                    } else if (makerCd != null && makerCd.length < 4) {
                        params.s_select_type = "detail";
                        params.s_maker_cd = makerCd;
                    }

                    $M.goNextPage('/sale/sale0501p01', $M.toGetParam(params), {popupStatus : ""});
                }
            });
        }
        
        // 기종에 따른 메이커 조회
        function goSearchMakerList() {
        	var param = {
        			s_ms_machine_type_cd : $M.getValue("s_ms_machine_type_cd")
        	}
        	
			$M.goNextPageAjax("/sale/sale0501/search/maker", $M.toGetParam(param), {method: "GET"},
				function (result) {
					if (result.success) {
						console.log("result : ", result);
						
						$("#s_maker_cd").combogrid({
							panelWidth: "300",
							idField: "code_value",
							textField : "code_name",
						});
						
						// 콤보그리드 다시 세팅
						$("#s_maker_cd").combogrid("grid").datagrid("loadData", result.makerList);

                        var msMakerCd = result.defaultMakerCd;
                        var msMakerCdArr = msMakerCd.split("#");

                        $('#s_maker_cd').combogrid("setValues", msMakerCdArr);
					}
				}
			);
        }

        // [14512] 숫자 클릭 시 'MS리스트' 팝업 호출 - 김경빈
        function myStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
            if (item.center_org_name.indexOf("전체총계") === -1) {
                return (item.center_org_name.indexOf("소계 ]") !== -1) ? "aui-sub-total-popup" : "aui-popup";
            }
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 기본 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="70px">
                                <col width="300px">
                        		<col width="45px">
								<col width="100px">
                                <col width="55px">
                                <col width="400px">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년월</th>
								<td>
									<div class="form-row inline-pd">
										<div class="col-3">
											<select class="form-control" id="s_start_year" name="s_start_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<option value="${i}" <c:if test="${i==inputParam.s_start_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-2">
											<select class="form-control" id="s_start_mon" name="s_start_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_start_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-1 text-center">~</div>
										<div class="col-3">
											<select class="form-control" id="s_end_year" name="s_end_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-2">
											<select class="form-control" id="s_end_mon" name="s_end_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
								</td>
								<th>기종</th>
								<td>
									<select class="form-control" id="s_ms_machine_type_cd" name="s_ms_machine_type_cd" onchange="goSearchMakerList()">
										<c:forEach items="${codeMap['MS_MACHINE_TYPE']}" var="item">
											<option value="${item.code_value}">${item.code_name}</option>
										</c:forEach>
									</select>
								</td>								
                                <th>메이커</th>
                                <td>
                                    <input class="form-control" style="width: 99%;" type="text" id="s_maker_cd"
                                           name="s_maker_cd" easyui="combogrid" required="required" alt="메이커"
                                           easyuiname="makerList" panelwidth="300" idfield="code_value"
                                           textfield="code_name" multi="Y"/>
                                </td>
                                <td class="">
                                    <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <!-- /기본 -->
                    <!-- 부서별 조회결과 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <div class="btn-group">
                            <div class="right">
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <div id="auiGrid" style="margin-top: 5px; height: 650px"></div>
                </div>
            </div>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>