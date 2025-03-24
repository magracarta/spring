<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 영업 > 장비관리 > 장비원가관리 > null > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2021-08-02 15:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">

		var auiGrid;
		var makerCdForApply; // 조회한 메이커의 환율적용하기 위한 변수! (조회 후 셀렉트박스를 바꾸는 예외방지)
		var costPriceSeq = []; // 원가순번 배열(상세팝업 열때 원가순번이 있으면 이걸 사용)
		var planSeq = []; // 장비순번 배열(상세팝업 열때 원가순번이 없으면 이걸 사용)
		var dataStartIndex = 3; // 컬럼에 데이터가 시작되는 인덱스(0부터 시작)
		var machineList = []; // 헤더에 표시될 장비 목록
		var isTempSaved = false; // 환율적용, true일 경우, apply_n으로 저장 후 불러옴

		$(document).ready(function () {
			// 그리드 생성
			createAUIGrid();
			goSearch();
		});

		// 저장 반영
		function goSave() {
			if (AUIGrid.getGridData(auiGrid).length == 0) {
				alert("적용할 데이터가 없습니다.");
				return false;
			}

			var editedCols = AUIGrid.getEditedRowColumnItems(auiGrid);
			var editedList = [];

			for (var i = 0; i < editedCols.length; ++i) {
				var object = editedCols[i];

				var fieldName = "";

				// fieldName을 찾음
				for (var key in object) {
					if (!key.startsWith("machine_name")) {
						fieldName = object[key];
						break;
					}
				}

				// fieldName에 해당하는 값
				for (var key in object) {
					if (key.startsWith("machine_name")) {
						// SEQ로 machineCostSeq 를 찾음
						var machineCostSeq = costPriceSeq[key.substring(13)];
						var obj = {};
						obj["mch_cost_price_seq"] = machineCostSeq;
						obj[fieldName] = object[key];
						editedList.push(obj);
					}
				}
			}

			// 중복삭제
			var editedSeq = [];
			for (var i = 0; i < editedList.length; ++i) {
				if (editedSeq.indexOf(editedList[i].mch_cost_price_seq) == -1) {
					editedSeq.push(editedList[i].mch_cost_price_seq);
				}
			}

			if (isTempSaved == false && editedSeq.length == 0) {
				alert("적용할 데이터가 없습니다.");
				return false;
			}

			var list = [];
			for (var i = 0; i < costPriceSeq.length; ++i) {
				if (costPriceSeq[i] != 0) {
					// 환율적용했으면 페이지 전체를 저장
					// 환율적용안했으면 수정한 장비만 저장
					if (isTempSaved == false && editedSeq.indexOf(costPriceSeq[i]) == -1) {
						continue;
					}
					var param = {
						mch_cost_price_seq : costPriceSeq[i],
						// apply_er_price : AUIGrid.getItemByRowId(auiGrid, "apply_er_price")["machine_name_"+i] || 0,
						min_sale_price : AUIGrid.getItemByRowId(auiGrid, "min_sale_price")["machine_name_"+i] || 0,
						agency_adjust_amt : AUIGrid.getItemByRowId(auiGrid, "agency_adjust_amt")["machine_name_"+i] || 0,
						list_adjust_amt : AUIGrid.getItemByRowId(auiGrid, "list_adjust_amt")["machine_name_"+i] || 0,
						pro_adjust_amt : AUIGrid.getItemByRowId(auiGrid, "pro_adjust_amt")["machine_name_"+i] || 0,
					}
					list.push(param);
				}
			}

			// 리스트를 form으로 만듬
			if (list.length == 0) {
				alert("적용할 데이터가 없습니다.");
				return false;
			}

			console.log(list);
			// 예약사항이 있는지 확인 후 예약사항이 없으면 반영
			fnSave(list);
		}

		// 검색 & 환율적용
		function fnResult(result) {
			console.log(result);
			if (result.success) {
				makerCdForApply = "";
				makerCdForApply = $M.getValue("s_maker_cd");

				if (result.costPriceSeq) {
					for (var key in result.costPriceSeq) {
					   if (key.startsWith("machine_")) {
						   costPriceSeq.push($M.toNum(result.costPriceSeq[key]));
					   }
					}
				}

				if (result.plantSeq) {
					for (var key in result.plantSeq) {
					   if (key.startsWith("machine_")) {
						   plantSeq.push($M.toNum(result.plantSeq[key]));
					   }
					}
				}

				$("#money_unit_cd").html(result.moneyUnitCd);
				machineList = [];
				machineList = result.colList;
				columnLayout = [];
				if (result.list) {
					columnLayout = [
						{
							headerText: "모델",
							dataField: "col_01",
							width: "100",
		                    minWidth: "30",
		                    style: "aui-center",
		                    colSpan: 2, // 헤더 가로병합
		                    cellColMerge: true, // 셀 가로병합
		                    cellColSpan: 2, // 셀 가로병합
		                    cellMerge: true, // 셀 세로병합
		                    renderer: { // 템플릿 렌더러 사용
		                        type: "TemplateRenderer"
		                    },
							visible: false,
		                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                    	if(item.col_01.indexOf("+")>-1) {
		    						return "aui-as-tot-row-style";
		    					}
		                        if(value.indexOf("<br>") != -1
		                        		|| value == "CIF Price"
		                        		|| value == "기타비용"
		                        		|| value == "통관/내륙운반"
		                        		|| value == "기본지급품"
		                        		|| value == "일반관리비"
		                        		|| value == "마진"
		                        		|| value == "신장비도입") {
		                            return "aui-bg-darker-gray";
		                        } else {
		                        	return "aui-as-cell-row-style";
		                        }
		                    },
						},
						{
							headerText: "구분",
		                    dataField: "col_02",
		                    width: "190",
		                    minWidth: "50",
		                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
		                    	return "aui-as-cell-row-style";
		                    },
		                },
		                {
		                	dataField: "col_03",
		                	visible : false
		                }
					];
					for (var i = 0; i < result.colList.length; ++i) {
						var col = {
							dataField: "machine_name_"+i,
							headerText : result.colList[i].machine_name,
							width: "100",
							minWidth: "50",
							editable : true,
							headerStyle : "aui-popup",
							style : "aui-right",
							labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
								return value == 0 ? "" : $M.setComma(value);
							},
							styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
								// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
								// if (item.col_01 === '최저판매가' || item.col_01 === '대리점공급가조정' || item.col_01 === '리스트가조정' || item.col_01 === '프로모션가조정') {
								if (item.col_01 === '최저판매가' || item.col_01 === '위탁판매점공급가조정' || item.col_01 === '리스트가조정' || item.col_01 === '프로모션가조정') {
									return "aui-editable";
								}
		                        // if(rowIndex == 14 // 적용환율
		                        // 		|| rowIndex == 65 // 최저판매가
		                        // 		|| rowIndex == 66 // 대리점공급가조정
		                        // 		|| rowIndex == 68 // 리스트가조정
		                        // 		|| rowIndex == 70) { // 프로모션가조정
		                        //     return "aui-editable";
		                        // }
		                    },
						}
						columnLayout.push(col);
					}
				}
				AUIGrid.changeColumnLayout(auiGrid, columnLayout);
				AUIGrid.setGridData(auiGrid, result.list);
				// [15324] 틀 고정
				AUIGrid.setFixedColumnCount(auiGrid, 1);
			}
		}

		// 환율적용
		function goApply() {
			var exchange_rate = $M.getValue("exchange_rate");
			if (exchange_rate == "") {
				alert("환율을 입력해주세요");
				$("#exchange_rate").focus();
				return false;
			}
			if (AUIGrid.getGridData(auiGrid).length == 0) {
				alert("적용할 데이터가 없습니다.");
				return false;
			}

			var param = {
				"s_maker_cd": makerCdForApply,
				"exchange_rate": $M.getValue("exchange_rate")
			};
			costPriceSeq = [];
			plantSeq = [];
			isTempSaved = true; // 환율적용, apply_n으로 저장 후 불러옴
			$M.goNextPageAjaxMsg("환율을 적용하시겠습니까?\n반영 전까지 임시로 저장됩니다.", this_page + "/exchangeApply", $M.toGetParam(param), {method: "POST"},
					function(result) {
						fnResult(result);
			});
		}

		// 검색기능
		function goSearch() {
			var param = {
				"s_maker_cd": $M.getValue("s_maker_cd"),
				"s_apply_yn": "Y"
			};
			costPriceSeq = [];
			plantSeq = [];
			$("#money_unit_cd").html("");
			isTempSaved = false;
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: "GET"},
					function(result) {
						fnResult(result);
			});
		}

		// 액셀다운로드
		function fnDownloadExcel() {
			fnExportExcel(auiGrid, "장비원가관리");
		}

		//그리드생성
		function createAUIGrid() {
			var gridPros = {
				height: 515,
				showHeader : true,
				enableSorting : false,
				showRowNumColumn: false,
                enableCellMerge: true, // 셀병합 사용여부
                cellMergeRowSpan: true,
                editable : true,
                rowIdField : "col_03",
				rowStyleFunction : function(rowIndex, item) {
					if(item.col_01.indexOf("+")>-1) {
						return "aui-as-tot-row-style";
					}
				},
			};

			// 컬럼레이아웃
			var columnLayout = [];

			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
			AUIGrid.setGridData(auiGrid, []);
			AUIGrid.bind(auiGrid, "headerClick", function(event) {
				// 모델 컬럼 제외
				var colIndex = event.columnIndex;
				if (colIndex < dataStartIndex) {
					return false;
				}

				// 신규등록일 경우 plant로 찾음
		        var dataIndex = colIndex-dataStartIndex;
		        var costSeq = costPriceSeq[dataIndex];
				var applyYn = isTempSaved ? 'N' : 'Y';
		        var param = {
		       	  	mch_cost_price_seq : costPriceSeq[dataIndex],
		       	  	machine_plant_seq : machineList[dataIndex].machine_plant_seq,
					price_apply_yn : applyYn
		        }

				$M.goNextPage('/sale/sale0207p01', $M.toGetParam(param), {popupStatus : ''});
			});

			AUIGrid.bind(auiGrid, "cellEditBegin", function(event) {
				// 모델 컬럼 제외
				var colIndex = event.columnIndex;
				if (colIndex < dataStartIndex) {
					return false;
				}
				var dataIndex = colIndex-dataStartIndex;
		        var costSeq = costPriceSeq[dataIndex];
		        if (costSeq == 0) {
		        	alert("최초 등록 후 수정가능합니다.\n등록하려면 헤더에 장비명을 눌러주세요!");
		        	return false;
		        }

		        switch (event.item.col_01) {
		        	// case 14: // 적용환율
		        	// 	return true;
		        	// case 65: // 최저판매가
					case '최저판매가':
		        		return true;
		        	// case 66: // 대리점공급가조정
					// [재호] Q&A : 17751 대리점 → 위탁판매점으로 텍스트 교체
					// case '대리점공급가조정':
					case '위탁판매점공급가조정':
		        		return true;
		        	// case 68: // 리스트가조정
					case '리스트가조정':
		        		return true;
		        	// case 70: // 프로모션가조정
					case '프로모션가조정':
		        		return true;
		        	default :
		        		return false;
		        }
			});

			AUIGrid.bind(auiGrid, "cellEditEnd", function(event) {
				// 모델 컬럼 제외
				if (event.value == "") {
					return null;
				}
			});

			$("#auiGrid").resize();
		}

		function fnSave(list) {
			var param = {
				"s_mch_cost_price_seq_arr" : list.map(x => x.mch_cost_price_seq)
			}
			$M.goNextPageAjax(this_page + '/check_reserve', $M.toGetParam(param), {method : 'GET', loader : false, async : false},
					function(result) {
						if (result.success) {
							var frm = $M.jsonArrayToForm(list);
							$M.goNextPageAjaxMsg("반영하시겠습니까?", this_page+"/apply", frm, {method : 'POST'},
									function(result) {
										if(result.success) {
											$M.setValue("s_maker_cd", makerCdForApply);
											goSearch();
										}
									}
							);
						}
			});
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
								<col width="50px">
								<col width="100px">
								<%-- <col width="70px"> --%>
								<col width="*">
							</colgroup>
							<tbody>
							<tr>
								<th>메이커</th>
								<td>
									<select id="s_maker_cd" name="s_maker_cd" class="form-control" onchange="goSearch()">
										<c:forEach items="${makers}" var="item">
											<option value="${item.maker_cd}">${item.maker_name}</option>
										</c:forEach>
									</select>
								</td>
								<td class="">
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>조회결과</h4>
						<div class="btn-group">
							<div class="right">
								<span id="money_unit_cd"></span>
								<input type="text" id="exchange_rate" name="exchange_rate" format="decimal">
								<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->

					<div id="auiGrid" style="height:555px; margin-top: 5px;"></div>

					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="right">
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
					<!-- /그리드 서머리, 컨트롤 영역 -->
				</div>

			</div>
			<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>
