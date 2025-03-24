<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 회계 > 장부 > 월별손익계산서 > 월별손익계산서 업로드 > null
-- 작성자 : 성현우
-- 최초 작성일 : 2020-07-17 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        $(document).ready(function () {
            createAUIGrid();
            changeYear();
        });
        
        function changeYear() {
        	if(fnChangeGridDataCnt(auiGrid) != 0){
            	var check = confirm("변경한 내역을 저장하지않고 넘어가시겠습니까?");
            	if(!check){
            		return false; 
            	}
			}
			
			var param = {
				"s_year" : $M.getValue("pnl_year")
			}
			
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), { method : "GET" }, function(result){
				if(result.success){
					AUIGrid.clearGridData(auiGrid);
					AUIGrid.setGridData(auiGrid,result.list);
				}
			});
        }

        // 날짜 Setting
        function fnSetYearMon(year, mon) {
            return year + (mon.length == 1 ? "0" + mon : mon);
        }

        // 저장
        function goSave() {
            if ($M.validation(document.main_form) == false) {
                return;
            }

            $M.setValue("salary_mon", fnSetYearMon($M.getValue("s_year"), $M.getValue("s_mon")));
            var frm = $M.toValueForm(document.main_form);

            var concatCols = [];
            var concatList = [];
            var gridIds = [auiGrid];
            for (var i = 0; i < gridIds.length; ++i) {
                concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
                concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
            }

            var gridForm = fnGridDataToForm(concatCols, concatList);
            $M.copyForm(gridForm, frm);

            $M.goNextPageAjaxSave(this_page + "/save", gridForm, {method: "POST"},
                function (result) {
                    if (result.success) {
                        fnClose();
                    }
                }
            );
        }
        
        // 초기화
		function fnReset(){
			
			var sYear = $M.getValue("pnl_year");
			var msg = sYear + "년 월별손익계산서를 삭제하시겠습니까?";
			
			var param = {
				"s_year" : sYear
			}
			
			$M.goNextPageAjaxMsg(msg, this_page + "/remove", $M.toGetParam(param), { method : "POST" }, function(result){
				if(result.success){
					location.reload();
				}
			});
		}

        // 닫기
        function fnClose() {
            window.close();
        }

        function createAUIGrid() {
            var gridPros = {
                noDataMessage: "엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여 넣기(Ctrl+V) 하십시오.",
                rowIdField: "_$uid",
                editable: true, // 수정 모드
                editableOnFixedCell: true,
                selectionMode: "multipleCells", // 다중셀 선택
                showStateColumn: true,
                softRemovePolicy: "exceptNew",
                wrapSelectionMove: true, // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
                enableFilter: true,
                softRemoveRowMode: false,
                // 체크박스 출력 여부
                showRowCheckColumn: false,
                // 전체선택 체크박스 표시 여부
                showRowAllCheckBox: false,
                showAutoNoDataMessage: false,
                rowStyleFunction : function(rowIndex, item) {
					if(item.pnl_name.indexOf(".") != -1) {
						return "aui-as-center-row-style";
					} else if(item.pnl_name.indexOf("상품매출원가_") != -1) {
						return "aui-as-tot-row-style";
					}
					return "";
				}
            };

            var columnLayout = [
                {
                    headerText: "과목",
                    dataField: "pnl_name",
                    style: "aui-center",
                    width: "170",
                    minWidth: "50"
                },
                {
                    headerText: "계",
                    dataField: "total",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "1월",
                    dataField: "pnl_amt_01",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "2월",
                    dataField: "pnl_amt_02",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "3월",
                    dataField: "pnl_amt_03",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "4월",
                    dataField: "pnl_amt_04",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "5월",
                    dataField: "pnl_amt_05",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "6월",
                    dataField: "pnl_amt_06",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "7월",
                    dataField: "pnl_amt_07",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "8월",
                    dataField: "pnl_amt_08",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "9월",
                    dataField: "pnl_amt_09",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "10월",
                    dataField: "pnl_amt_10",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "11월",
                    dataField: "pnl_amt_11",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                },
                {
                    headerText: "12월",
                    dataField: "pnl_amt_12",
                    dataType: "numeric",
                    formatString: "#,##0",
                    style: "aui-right",
                    width: "120",
                    minWidth: "50"
                }
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);

            $("#auiGrid").resize();
            
            AUIGrid.bind(auiGrid, "cellEditBegin", function (event) {
                if (!event.isClipboard) {
                    return false;
                } 
            });

        }
    </script>
</head>
<body class="bg-white">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <!-- 검색조건 -->
            <div class="search-wrap mt5">
                <table class="table">
                    <colgroup>
                        <col width="60px">
                    </colgroup>
                    <tbody>
                    <tr>
                        <th>지출년도</th>
                        <td>
                            <div class="form-row inline-pd">
                                <div class="col-auto">
                                    <select class="form-control essential-bg" id="pnl_year" name="pnl_year" required="required" alt="손익년도" onchange="javascript:changeYear();">
                                        <c:forEach var="i" begin="2000" end="${inputParam.s_current_year+1}" step="1" varStatus="status">
                                            <c:set var="year_option" value="${status.end - i + status.begin}"/>
                                            <option value="${year_option}" <c:if test="${year_option eq inputParam.s_year}">selected</c:if>>${year_option}년</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </div>
                        </td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <!-- /검색조건 -->
            <div class="title-wrap mt10">
                <h4>월별손익계산서 업로드</h4>
                <div class="right">
                    <div class="text-warning ml5">
                        ※ 엑셀에서 데이터를 복사(Ctrl+C) 하여 이곳에 붙여넣기(Ctrl+V) 하십시오.<br>
                        ※ 더존 경로 : 회계관리 > 결산/재무제표관리 > 관리용재무제표 > 기간별손익계산서
                    </div>
                </div>
                <div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
				</div>
            </div>
            <div id="auiGrid" style="margin-top: 5px; height: 550px;"></div>

            <!-- 그리드 서머리, 컨트롤 영역 -->
            <div class="btn-group mt10">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
            <!-- /그리드 서머리, 컨트롤 영역 -->
        </div>
    </div>
    <!-- /팝업 -->
</form>
</body>
</html>