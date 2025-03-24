<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > MS관리 > MS관리-부서별 > null > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-08-19 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        $(document).ready(function () {
            createAUIGrid();
            fnInit();

            goSearch();
        });
        
        function goAmtGraphPopup() {
        	var frm = document.main_form;
            //validationcheck
            if($M.validation(frm,
                {field:["s_start_year", "s_end_year", "s_ms_machine_sub_type_cd", "s_maker_cd"]})==false) {
                return;
            };

            if($M.getValue("s_maker_cd") == "") {
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

            if(makerCdArr.length > 9) {
                alert("메이커는 최대 9개까지 선택 가능합니다.\n현재 " + makerCdArr.length + "개 선택하셨습니다.");
                return;
            }

//             var endYear = $M.dateFormat($M.addYears($M.toDate($M.getValue("s_end_year")), 1), 'yyyy');
			var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var params = {
// 				"s_start_year" : $M.getValue("s_start_year"),
// 				"s_end_year" : endYear,
				"s_start_year" : $M.getValue("s_start_year"),
				"s_start_mon" : fnSetMM($M.getValue("s_start_mon")),
				"s_end_year" : $M.getValue("s_end_year"),
				"s_end_mon" : fnSetMM($M.getValue("s_end_mon")),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_ms_machine_sub_type_cd" : $M.getValue("s_ms_machine_sub_type_cd"),
                "s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd"),
				"s_maker_cd_str" : $M.getArrStr(makerCdArr)
			};
			
			var popupOption = 'scrollbars=yes, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=531, left=0, top=0';
			$M.goNextPage('/sale/sale0502p01', $M.toGetParam(params), {popupStatus : popupOption});
        }

        function fnInit() {
            var msMakerCd = "${defaultMakerCd}";
            var msMakerCdArr = msMakerCd.split("#");

            $('#s_maker_cd').combogrid("setValues", msMakerCdArr);
        }

		function goSearch() {
            var frm = document.main_form;
            //validationcheck
            if($M.validation(frm,
                {field:["s_start_year", "s_end_year", "s_ms_machine_sub_type_cd", "s_maker_cd"]})==false) {
                return;
            };

            if($M.getValue("s_maker_cd") == "") {
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

            if(makerCdArr.length > 9) {
                alert("메이커는 최대 9개까지 선택 가능합니다.\n현재 " + makerCdArr.length + "개 선택하셨습니다.");
                return;
            }

//             var endYear = $M.dateFormat($M.addYears($M.toDate($M.getValue("s_end_year")), 1), 'yyyy');
			var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
			var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));

			var params = {
				"s_start_year" : $M.getValue("s_start_year"),
				"s_start_mon" : fnSetMM($M.getValue("s_start_mon")),
				"s_end_year" : $M.getValue("s_end_year"),
				"s_end_mon" : fnSetMM($M.getValue("s_end_mon")),
				"s_start_dt" : startDt,
				"s_end_dt" : endDt,
				"s_ms_machine_sub_type_cd" : $M.getValue("s_ms_machine_sub_type_cd"),
                "s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd"),
				"s_maker_cd_str" : $M.getArrStr(makerCdArr)
			};

			console.log(params);

            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(params), {method: "GET"},
                function (result) {
                    if (result.success) {
						// 초기진입 무한로딩 현상 개선
						if ($.isEmptyObject(result.list[0])) {
							return;
						}
                        AUIGrid.setGridData(auiGrid, result.list);

//                           var colSizeList = AUIGrid.getFitColumnSizeList(auiGrid, true);
//                         // 구해진 칼럼 사이즈를 적용 시킴.
//                         AUIGrid.setColumnSizeList(auiGrid, colSizeList);
                    }
                }
            );
		}
		
		function fnSetDate(year, mon) {
			if(mon.length == 1) {
				mon = "0" + mon;
			}
			var sYearMon = year + mon;

			return $M.dateFormat($M.toDate(sYearMon), 'yyyyMM');
		}
		
		function fnSetMM(mon) {
			if(mon.length == 1) {
				mon = "0" + mon;
			}
			return mon;
		}

        function fnDownloadExcel() {
			fnExportExcel(auiGrid, "MS관리-시도별");
        }

        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: false,
				// fixedColumnCount : 4, // 고정칼럼 카운트 지정
                enableCellMerge : true,
                cellMergeRowSpan:  true,
                rowStyleFunction : function(rowIndex, item) {
                    if((item.ms_year.indexOf("소계") != -1 && item.ms_year.indexOf("[") == -1)
                        || (item.ms_year.indexOf("총계") != -1 && item.ms_year.indexOf("[") == -1)) {
                        return "aui-grid-row-depth3-style";
                    } else if(item.ms_year.indexOf("[") != -1) {
                        return "aui-ms-col-style";
                    }

                    return null;
                },
				// [23426] 총계 틀 고정
				fixedRowCount : 1,
            };

            var columnLayout = [
                {
                    headerText: "년도",
                    dataField: "ms_year",
					width : "140",
					minWidth : "20",
                    style: "aui-center",
                    cellMerge : true,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        if(value.indexOf("소계") != -1 || value.indexOf("총계") != -1) {
                            return value;
                        } else {
                            return value + "년";
                        }

                        return null;
                    }
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
                {
                    headerText : "메이커코드",
                    dataField : "maker_cd",
                    visible : false
                },
                {
                    headerText: "메이커",
                    dataField: "maker_name",
					width : "110",
					minWidth : "20",
                    style: "aui-center",
                },
                {
                    headerText: "Total",
                    dataField: "a_total",
					width : "65",
					minWidth : "20",
                    style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
                },
				{
					headerText: "서울",
					dataField: "a_seoul",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "경기",
					dataField: "a_gyeonggi",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "인천",
					dataField: "a_incheon",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "강원",
					dataField: "a_gangwon",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "충북",
					dataField: "a_chungbuk",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "충남",
					dataField: "a_chungnam",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "대전",
					dataField: "a_daejeon",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "경북",
					dataField: "a_gyeongbuk",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "대구",
					dataField: "a_daegu",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "경남",
					dataField: "a_gyeongnam",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "울산",
					dataField: "a_ulsan",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "부산",
					dataField: "a_busan",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "전북",
					dataField: "a_jeonbuk",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "전남",
					dataField: "a_jeonnam",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "광주",
					dataField: "a_gwangju",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction :CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "제주",
					dataField: "a_jeju",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        return value == "0"? "" : $M.setComma(value);
                    }
				},
				{
					headerText: "세종",
					dataField: "a_sejong",
					width : "60",
					minWidth : "20",
					style: "aui-center",
					styleFunction : CustomStyleFunction,
					labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
						return value == "0"? "" : $M.setComma(value);
					}
				},
		];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            $("#auiGrid").resize();

			AUIGrid.bind(auiGrid, "cellClick", function(event) {

				var startDt = fnSetDate($M.getValue("s_start_year"), $M.getValue("s_start_mon"));
				var endDt = fnSetDate($M.getValue("s_end_year"), $M.getValue("s_end_mon"));
				var makerCdList = $M.getValue("s_maker_cd");
				var makerCd = event.item.maker_cd;
				var subTypeCd = event.item.ms_machine_sub_type_cd;

				// 숫자 텍스트의 셀만 클릭되도록 변경
				if (event.headerText == "년도" || event.headerText == "메이커" || event.value == "" || event.item.ms_year.includes("총계")) {
					return;
				}

				// 메이커별 소계는 미니굴삭기의 규격코드 0102, 0103, 0104의 합계
				if (event.item.ms_year.includes("소계 ]")) {
					subTypeCd = "0102#0103#0104";
				}

				// 보낼 데이터
				var params = {
					"s_menu_type" : "sido",
					"s_area_code_str" : event.headerText, // 지역이름
					"s_sub_type_cd" : subTypeCd,
					"s_ms_mon" : startDt + "#" + endDt,
					"s_ms_year" : event.item.ms_year,
					"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd")
				};

				// 전체총계 셀 클릭시 모든 장비규격
				// if (event.item.ms_year.includes("전체총계")) {
				// 	params.s_sub_type_cd = "total";
				// }

				// 소계인 경우, 몇년도의 소계인지 찾아서 "s_ms_year" 파라미터 값을 넣어줌
				if (event.item.ms_year.includes("소계")) {
					for (var i=1; ; i++) {
						var test = AUIGrid.getCellValue(auiGrid, event.rowIndex - i, "ms_year");
						if (!test.includes("소계")) {
							params.s_ms_year = AUIGrid.getCellValue(auiGrid, event.rowIndex - i, "ms_year");
							break;
						}
					}
				}

				if (makerCd === "46") { // 기타
					params.s_select_type = "etc";
					// 메이커 선택 리스트에 기타가 포함되어있다면 제외
					if (makerCdList.includes("46")) {
						makerCdList = makerCdList.replaceAll("46", "");
					}
					params.s_maker_cd_str = makerCdList;

				} else if (makerCd.length < 4) { // 정상 메이커 코드
					params.s_select_type = "detail"; // AND IN maker_cd
					params.s_maker_cd_str = makerCd;

				} else {
					params.s_select_type = "total";
					params.s_maker_cd_str = makerCdList;
				}

				$M.goNextPage('/sale/sale0501p01', $M.toGetParam(params), {popupStatus : ""});
			});
		}

        // 기종에 따른 메이커 조회
        function goSearchMakerList() {
        	var param = {
        			"s_ms_machine_type_cd" : $M.getValue("s_ms_machine_type_cd")
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

		function CustomStyleFunction(rowIndex, columnIndex, value, headerText, item, dataField) {
			if (!item.ms_year.includes("총계")) {
				if (item.ms_year.includes("소계 ]")) {
					return "aui-sub-total-popup";
				}
				return "aui-popup";
			}
			return null;
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
								<col width="350px">
								<col width="45px">
								<col width="100px">
								<col width="55px">
								<col width="400px">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>조회년월</th>
                                <td>
                                    <%-- <div class="form-row inline-pd">
                                        <div class="col-auto">
											<select class="form-control" id="s_start_year" name="s_start_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<option value="${i}" <c:if test="${i==inputParam.s_current_year-1}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
                                        </div>
                                        <div class="col-auto text-center">~</div>
                                        <div class="col-auto">
											<select class="form-control" id="s_end_year" name="s_end_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<option value="${i}" <c:if test="${i==inputParam.s_current_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
                                        </div>
                                    </div> --%>
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
										<div class="col-auto text-center">~</div>
										<div class="col-3">
											<select class="form-control" id="s_end_year" name="s_end_year">
												<c:forEach var="i" begin="2000" end="${inputParam.s_current_year}" step="1">
													<option value="${i}" <c:if test="${i==inputParam.s_end_year}">selected</c:if>>${i}년</option>
												</c:forEach>
											</select>
										</div>
										<div class="col-3">
											<select class="form-control" id="s_end_mon" name="s_end_mon">
												<c:forEach var="i" begin="1" end="12" step="1">
													<option value="<fmt:formatNumber value="${i}" minIntegerDigits="1"/>" <c:if test="${i==inputParam.s_end_mon}">selected</c:if>>${i}월</option>
												</c:forEach>
											</select>
										</div>
									</div>
                                </td>
<!--                                 <th>규격</th> -->
<!--                                 <td> -->
<!-- 									<select class="form-control" id="s_ms_machine_sub_type_cd" name="s_ms_machine_sub_type_cd"> -->
<%-- 										<c:forEach items="${codeMap['MS_MACHINE_SUB_TYPE']}" var="item"> --%>
<%-- 											<option value="${item.code_value}">${item.code_name}</option> --%>
<%-- 										</c:forEach> --%>
<!-- 									</select> -->
<!--                                 </td> -->
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
									<input class="form-control" style="width: 99%;" type="text" id="s_maker_cd" name="s_maker_cd" easyui="combogrid" required="required" alt="메이커"
                                           easyuiname="makerList" panelwidth="300" idfield="code_value" textfield="code_name" multi="Y" />
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
                    <div id="auiGrid" style="margin-top: 5px; height: 650px"></div><!-- /부서별 조회결과 -->
                </div>

            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>