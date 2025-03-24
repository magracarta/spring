<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 쿠폰관리 > 프로모션관리 > 프로모션 신규등록 > null
-- 작성자 : 김태훈
-- 최초 작성일 : 2020-04-07 19:54:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
	
		<%-- 여기에 스크립트 넣어주세요. --%>
		
		var auiGridTop1;
		var auiGridTop2;
		var auiGridTop3;
		var auiGridTop4;
		var auiGridTop5;
		var auiGridTop6;
		var auiGridMidLeft;
		var auiGridMidRight;
		var auiGridBom;

		// 고객앱 > 마이페이지 > 이벤트 에서 노출하는 이미지 첨부파일이 추가됨에 따라 변수 추가(2023.08.02)
		// 'attach': 첨부이미지
		// 'banner': 이벤트 목록 배너
		// 'detail': 이벤트 상세이미지
		var fileType = 'attach';
		var fileIndex = 0;
		var fileCount = 0;
		
		// 첨부파일의 index 변수
		var attachFileIndex = 1;
		// 첨부할 수 있는 파일의 개수
		var attachFileCount = 1;
		// 고객앱 - 마이페이지 - 이벤트 메뉴에서 노출하는 배너이미지, 상세이미지 추가(2023.08.02.)
		// 배너이미지 파일의 index 변수
		var bannerImageFileIndex = 1;
		// 첨부할 수 있는 배너이미지 파일의 개수
		var bannerImageFileCount = 1;
		// 상세이미지 파일의 index 변수
		var detailImageFileIndex = 1;
		// 첨부할 수 있는 상세이미지 파일의 개수
		var detailImageFileCount = 5;
		
		$(document).ready(function() {
			// AUIGrid 생성
			createAUIGridTop1();
			createAUIGridTop2();
			createAUIGridTop3();
			createAUIGridTop4();
			createAUIGridTop5();
			createAUIGridTop6();
			
			createAUIGridMidLeft();
			createAUIGridMidRight();
			createAUIGridBom();
			
		});
		
		function fnAddFile(file_type){
			var param = {
				upload_type : 'SERVICE',
				file_type : 'img',
			}
			switch (file_type){
				case 'attach':
					fileType = file_type;
					fileIndex = attachFileIndex;
					fileCount = attachFileCount;
					break;
				case 'banner':
					fileType = file_type;
					fileIndex = bannerImageFileIndex;
					fileCount = bannerImageFileCount;
					param.max_width = 716;
					param.max_height = 200;
					param.pixel_resize_yn = 'Y';
					break;
				case 'detail':
					fileType = file_type;
					fileIndex = detailImageFileIndex;
					fileCount = detailImageFileCount;
					break;
				default:
					alert("파일 찾기 중 에러가 발생했습니다. 관리자에게 문의해주세요.");
					return false;
			}
			if($("input[name^="+fileType+"][value != '0']").size() >= fileCount) {
				alert("파일은 " + fileCount + "개만 첨부하실 수 있습니다.");
				return false;
			}
			openFileUploadPanel('setFileInfo', $M.toGetParam(param));
		}
		
		function setFileInfo(result) {
			var str = '';
			str += '<div class="table-attfile-item file_' + fileType + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			// str += '<input type="hidden" name=' + fileType + '_file_seq_' + fileIndex + ' value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(`' + fileType + fileIndex + '`, ' + result.file_seq + ', `'+ fileType + '`)"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.'+fileType+'_file_div').append(str);
            $M.setValue(fileType+fileIndex+"_file_seq", result.file_seq);
			switch (fileType){
				case 'attach':
					attachFileIndex = ++fileIndex;
					break;
				case 'banner':
					bannerImageFileIndex = ++fileIndex;
					break;
				case 'detail':
					detailImageFileIndex = ++fileIndex;
					break;
				default:
					alert("파일 첨부 중 에러가 발생했습니다. 관리자에게 문의해주세요.");
					return false;
			}
		}

		// 첨부파일 삭제
		function fnRemoveFile(file_index, file_seq, file_type) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".file_" + file_index).remove();
				$M.setValue(file_index+"_file_seq", 0);
				switch (file_type){
					case 'attach':
						attachFileIndex--;
						break;
					case 'banner':
						bannerImageFileIndex--;
						break;
					case 'detail':
						detailImageFileIndex--;
						// 상세이미지 element index 앞으로 채우기
						fileType = file_type;
						for (var i = 1; i <= detailImageFileCount; i++){
							if ($M.getValue("detail"+i+"_file_seq") == "0"){
								fileIndex = i;
								var currentDtlFileCnt = detailImageFileIndex;
								for (var j = fileIndex+1; j <= currentDtlFileCnt; j++){
									var fileInfo = {file_seq: '', file_name: 'a'};
									fileInfo.file_seq = $M.getValue("detail"+j+"_file_seq");
									fileInfo.file_name = $(".file_detail"+j).children("a")[0].innerHTML;
									$(".file_detail" + j).remove();
									setFileInfo(fileInfo);
								}
								$M.setValue("detail"+ currentDtlFileCnt +"_file_seq", 0);
								break;
							}
						}
						break;
					default:
						alert("파일 삭제 중 에러가 발생했습니다. 관리자에게 문의해주세요.");
						return false;
				}
			} else {
				return false;
			}
		}
		
		function goSearch() {
			if($M.validation(document.main_form) == false) { 
				return;
			};
			var frm = fnProcessForm();
			if (frm == false) {
				return false;
			}
			$M.goNextPageAjax(this_page+"/search", frm, {method : 'GET'},
					function(result) {
				    	if(result.success) {
				    		AUIGrid.setGridData(auiGridBom, result.list);
				    		$("#total_cnt").html(result.total_cnt);
						}
					}
				);
		}
		
		function goSave() {
			if ($M.getValue("end_dt") < "${inputParam.s_current_dt}") {
				alert("종료날짜가 오늘 이전인 프로모션을 등록시킬 수 없습니다.");
				return false;
			}
			if($M.validation(document.main_form, {field:["start_dt", "end_dt", "title", "content", "apply_condition_ao"]}) == false) { 
				return;
			};
			if($M.checkRangeByFieldName('start_dt', 'end_dt', true) == false) {				
				return;
			}; 
			
			var frm = fnProcessForm();
			if (frm == false) {
				return false;
			}
			
			if ($M.getValue("benefit_type_md") == "") {
				alert("혜택 구분을 선택하세요.");
				return false;
			}
			
			if ($M.getValue("benefit_type_md") == "D") {
				if ($M.getValue("apply_type_ao") == "") {
					alert("혜택할인을 선택하세요.");
					return false;
				}
			}
			
			if ($M.getValue("benefit_type_md") == "M" && $M.toNum($M.getValue("benefit_amt")) == 0) {
				alert("혜택금액을 입력하세요.");
				$("#benefit_amt").focus();
				return false;
			}
			
			if (AUIGrid.getGridData(auiGridBom).length == 0) {
				alert("프로모션 대상자가 없습니다. 조회 후 처리하세요.");
				return false;
			}

			// 적용대상 고객
			var targetList = AUIGrid.getGridData(auiGridBom);
			var param = {
				org_code : $M.getValue("org_code"),
				file_seq : $M.getValue("attach1_file_seq"),
				// 고객앱 > 마이페이지 > 이벤트 배너, 상세이미지 추가(2023.08.02.)
				rep_file_seq : $M.getValue("banner1_file_seq"),
				dtl_file_seq_1 : $M.getValue("detail1_file_seq"),
				dtl_file_seq_2 : $M.getValue("detail2_file_seq"),
				dtl_file_seq_3 : $M.getValue("detail3_file_seq"),
				dtl_file_seq_4 : $M.getValue("detail4_file_seq"),
				dtl_file_seq_5 : $M.getValue("detail5_file_seq"),
				title : $M.getValue("title"),
				start_dt : $M.getValue("start_dt"),
				end_dt : $M.getValue("end_dt"),
				content : $M.getValue("content"),
				apply_target_ao : $M.getValue("apply_target_ao"),
				apply_condition_ao : $M.getValue("apply_condition_ao"),
				apply_type_ao : $M.getValue("apply_type_ao"),
				target_maker_yn : $M.getValue("target_maker_yn"),
				target_mch_plant_yn : $M.getValue("target_mch_plant_yn"),
				target_mch_yn : $M.getValue("target_mch_yn"),
				target_sale_dt_yn : $M.getValue("target_sale_dt_yn"),
				target_sale_mem_yn : $M.getValue("target_sale_mem_yn"),
				target_center_yn : $M.getValue("target_center_yn"),
				condition_aio : $M.getValue("condition_aio"),
				condition_ard : $M.getValue("condition_ard"),
				condition_acs : $M.getValue("condition_acs"),
				benefit_type_md : $M.getValue("benefit_type_md"),
				benefit_amt : $M.getValue("benefit_amt"),
				type_wares_yn : $M.getValue("type_wares_yn"),
				type_trip_yn : $M.getValue("type_trip_yn"),
				type_part_yn : $M.getValue("type_part_yn"),
				type_wares_dc_rate : $M.getValue("type_wares_dc_rate"),
				type_trip_dc_rate : $M.getValue("type_trip_dc_rate"),
				type_part_dc_rate : $M.getValue("type_part_dc_rate"),
				part_output_price_yn : $M.getValue("part_output_price_yn"),
				part_exclude_yn : $M.getValue("part_exclude_yn"),
				maker_cd_str : $M.getArrStr(AUIGrid.getGridData(auiGridTop1), {key : 'maker_cd'}),
				machine_plant_seq_str : $M.getArrStr(AUIGrid.getGridData(auiGridTop2), {key : 'machine_plant_seq'}),
				machine_seq_str : $M.getArrStr(AUIGrid.getGridData(auiGridTop3), {key : 'machine_seq'}),
				sale_st_dt_str : $M.getArrStr(AUIGrid.getGridData(auiGridTop4), {key : 'sale_st_dt'}),
				sale_ed_dt_str : $M.getArrStr(AUIGrid.getGridData(auiGridTop4), {key : 'sale_ed_dt'}),
				pro_mem_no_str : $M.getArrStr(AUIGrid.getGridData(auiGridTop5), {key : 'pro_mem_no'}),
				center_org_code_str : $M.getArrStr(AUIGrid.getGridData(auiGridTop6), {key : 'center_org_code'}),
				part_output_price_cd_str : $M.getArrStr(AUIGrid.getGridData(auiGridMidLeft), {key : 'part_output_price_cd'}),
				part_no_str : $M.getArrStr(AUIGrid.getGridData(auiGridMidRight), {key : 'part_no'}),
				cust_no_str : $M.getArrStr(targetList, {key : 'cust_no'}),
				cust_machine_seq_str : $M.getArrStr(targetList, {key : 'cust_machine_seq'}),
			};
			$M.goNextPageAjaxSave(this_page, $M.toGetParam(param), {method : 'POST'},
					function(result) {
				    	if(result.success) {
				    		alert("저장이 완료되었습니다.");
			    			fnList();
						}
					}
				);
		}
		
		function fnProcessForm() {
			$M.getValue("target_maker_yn_check") == "" ? $M.setValue("target_maker_yn", "N") : $M.setValue("target_maker_yn", "Y");
			$M.getValue("target_mch_plant_yn_check") == "" ? $M.setValue("target_mch_plant_yn", "N") : $M.setValue("target_mch_plant_yn", "Y");
			$M.getValue("target_mch_yn_check") == "" ? $M.setValue("target_mch_yn", "N") : $M.setValue("target_mch_yn", "Y");
			$M.getValue("target_sale_dt_yn_check") == "" ? $M.setValue("target_sale_dt_yn", "N") : $M.setValue("target_sale_dt_yn", "Y");
			$M.getValue("target_sale_mem_yn_check") == "" ? $M.setValue("target_sale_mem_yn", "N") : $M.setValue("target_sale_mem_yn", "Y");
			$M.getValue("target_center_yn_check") == "" ? $M.setValue("target_center_yn", "N") : $M.setValue("target_center_yn", "Y");
			
			$M.getValue("type_part_yn_check") == "" ? $M.setValue("type_part_yn", "N") : $M.setValue("type_part_yn", "Y");
			$M.getValue("type_trip_yn_check") == "" ? $M.setValue("type_trip_yn", "N") : $M.setValue("type_trip_yn", "Y");
			$M.getValue("type_wares_yn_check") == "" ? $M.setValue("type_wares_yn", "N") : $M.setValue("type_wares_yn", "Y");
			$M.getValue("part_output_price_yn_check") == "" ? $M.setValue("part_output_price_yn", "N") : $M.setValue("part_output_price_yn", "Y");
			$M.getValue("part_exclude_yn_check") == "" ? $M.setValue("part_exclude_yn", "N") : $M.setValue("part_exclude_yn", "Y");
			
			$M.getValue("benefit_type_md_check") == "M" ? $M.setValue("benefit_type_md", "M") : $M.setValue("benefit_type_md", "D");
			
			if ($M.getValue("target_maker_yn") == "N" && 
				$M.getValue("target_mch_plant_yn") == "N" &&
				$M.getValue("target_mch_yn") == "N" &&
				$M.getValue("target_sale_dt_yn") == "N" && 
				$M.getValue("target_sale_mem_yn") == "N" &&
				$M.getValue("target_center_yn") == "N") {
				alert("메이커, 모델, 차대번호, 판매일자, 마케팅담당, 담당센터 중 최소 한 개 이상의 적용범위를 선택해주세요.");
				return false;
			}
			
			var top1Cnt = AUIGrid.getGridData(auiGridTop1); // 메이커
			var top2Cnt = AUIGrid.getGridData(auiGridTop2); // 모델
			var top3Cnt = AUIGrid.getGridData(auiGridTop3); // 차대
			var top4Cnt = AUIGrid.getGridData(auiGridTop4); // 판매일자
			var top5Cnt = AUIGrid.getGridData(auiGridTop5); // 영업담당
			var top6Cnt = AUIGrid.getGridData(auiGridTop6); // 담당센터
			var leftCnt = AUIGrid.getGridData(auiGridMidLeft); // 부품판가
			var rightCnt = AUIGrid.getGridData(auiGridMidRight); // 제외부품
			
			if (top1Cnt == 0 && top2Cnt == 0 && top3Cnt == 0 && top4Cnt == 0 && top5Cnt == 0 && top6Cnt == 0) {
				alert("적용 범위 중 최소 한 개 이상의 조건을 추가해주세요.");
				return false;
			}
			
			// 판매일자 빈칸 체크
			var isValidSaleDt = true;
			for (var i = 0; i < top4Cnt.length; ++i) {
				if (top4Cnt[i].sale_st_dt == "" || top4Cnt[i].sale_ed_dt == "") {
					isValidSaleDt = false;
					break;
				} else {
					if( Number(top4Cnt[i].sale_st_dt.replace(/-/gi,"")) > Number(top4Cnt[i].sale_ed_dt.replace(/-/gi,"")) ) {
						isValidSaleDt = false;
						break;
					}
				}
			}
			if (isValidSaleDt == false) {
				alert("판매일자 시작 또는 종료에 유효하지 않은 값이 있습니다.");
				return false;
			}

			var frm = $M.toValueForm(document.main_form);
			var concatCols = [];
			var concatList = [];
			var gridIds = [auiGridTop1, auiGridTop2, auiGridTop3, auiGridTop4, auiGridTop5, auiGridTop6, auiGridMidLeft, auiGridMidRight];
			for (var i = 0; i < gridIds.length; ++i) {
				concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
				concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
			}
			var gridForm = fnGridDataToForm(concatCols, concatList);
			$M.copyForm(gridForm, frm);
			return gridForm;
		}
		
		// 메이커 추가
		function goAddMaker() {
			var params = {
				"parent_js_name" : "fnSetMaker",
				"s_all_yn" : "Y"
			};
			var popupOption = "scrollbars=no, resizable-1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=400, height=500, left=0, top=0";
			$M.goNextPage('/sale/sale0504p02', $M.toGetParam(params), {popupStatus : popupOption});
		}
		
		function fnSetMaker(row) {
			if(AUIGrid.getItemsByValue(auiGridTop1, "maker_cd", row.maker_cd).length == 0) {
				AUIGrid.addRow(auiGridTop1, {"maker_cd":row.maker_cd,"maker_name":row.maker_name}, 'last');
			}
		}
		
		// 메이커 삭제
		function fnRemoveMaker() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop1);
			if (checkedItems.length == 0) {
				alert("체크된 메이커가 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop1, checkedItems[i]._$uid);	
				}
			}
		}
		
		// 모델추가
		function goAddModel() {
			openSearchModelPanel("fnSetModel", "N");
		}
		
		function fnSetModel(row) {
			console.log(row);
			if(AUIGrid.getItemsByValue(auiGridTop2, "machine_plant_seq", row.machine_plant_seq).length == 0) {
				AUIGrid.addRow(auiGridTop2, {"machine_plant_seq":row.machine_plant_seq,"machine_name":row.machine_name}, 'last');
			}
		}
		
		// 모델 삭제
		function fnRemoveModel() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop2);
			if (checkedItems.length == 0) {
				alert("체크된 모델이 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop2, checkedItems[i]._$uid);	
				}
			}
		}
		
		// 차대번호추가 
		function goAddBodyNo() {
			openSearchDeviceHisPanel("fnSetBodyNo");
		}
		
		function fnSetBodyNo(row) {
			if(AUIGrid.getItemsByValue(auiGridTop3, "machine_seq", row.machine_seq).length == 0) {
				AUIGrid.addRow(auiGridTop3, {"machine_seq":row.machine_seq,"body_no":row.body_no}, 'last');
			}
		}
		
		// 차대번호 삭제
		function fnRemoveBodyNo() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop3);
			if (checkedItems.length == 0) {
				alert("체크된 차대번호가 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop3, checkedItems[i]._$uid);	
				}
			}
		}
		
		// 판매일자 추가
		function goAddSaleDt() {
			AUIGrid.addRow(auiGridTop4, {"sale_st_dt":"","sale_ed_dt":""}, 'last');
		}
		
		// 판매일자 삭제
		function fnRemoveSaleDt() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop4);
			if (checkedItems.length == 0) {
				alert("체크된 판매일자가 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop4, checkedItems[i]._$uid);	
				}
			}
		}
		
		function goAddSaleMemNo() {
			openMemberOrgPanel("fnSetSaleMemNo", "N");
		}
		
		function fnSetSaleMemNo(row) {
			if(row.mem_no == "") {
				return false;
			}
			if(AUIGrid.getItemsByValue(auiGridTop5, "pro_mem_no", row.mem_no).length == 0) {
				AUIGrid.addRow(auiGridTop5, {"pro_mem_no":row.mem_no,"mem_name":row.mem_name}, 'last');
			}
		}
		
		// 영업담당 삭제
		function fnRemoveSaleMemNo() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop5);
			if (checkedItems.length == 0) {
				alert("체크된 마케팅담당이 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop5, checkedItems[i]._$uid);	
				}
			}
		}
		
		// 센터 추가
		function goAddCenter() {
			openOrgMapCenterPanel("fnSetCenter");
		}
		
		function fnSetCenter(row) {
			if(AUIGrid.getItemsByValue(auiGridTop6, "center_org_code", row.org_code).length == 0) {
				AUIGrid.addRow(auiGridTop6, {"center_org_code":row.org_code,"center_org_name":row.org_name}, 'last');
			}
		}
		
		// 센터 삭제
		function fnRemoveCenter() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridTop6);
			if (checkedItems.length == 0) {
				alert("체크된 센터가 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridTop6, checkedItems[i]._$uid);	
				}
			}
		}
		
		// 부품판가산출코드 추가
		function fnAddPartOutput() {
			if ($M.getValue("selectd_code_value") == "") {
				alert("부품판가 산출코드를 선택해주세요.");
				$("#selectd_code_value").focus();
			} else {
				var codeValue = $M.getValue("selectd_code_value");
				var codeName = $( "#selectd_code_value option:selected" ).text();
				if(AUIGrid.getItemsByValue(auiGridMidLeft, "part_output_price_cd", codeValue).length == 0) {
					AUIGrid.addRow(auiGridMidLeft, {"part_output_price_cd":codeValue,"part_output_price_name":codeName}, 'last');
				}
			}
		}
		
		// 부품판가 산출코드 삭제
		function fnRemovePartOutput() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridMidLeft);
			if (checkedItems.length == 0) {
				alert("체크된 부품판가 산출코드가 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridMidLeft, checkedItems[i]._$uid);	
				}
			}
		}
		
		// 부품추가
		function goAddPart() {
			openSearchPartPanel("fnSetPart", "N");
		}
		
		function fnSetPart(row) {
			if(AUIGrid.getItemsByValue(auiGridMidRight, "part_no", row.part_no).length == 0) {
				AUIGrid.addRow(auiGridMidRight, {"part_no":row.part_no,"part_name":row.part_name}, 'last');
			}
		}
		
		function fnRemovePart() {
			var checkedItems = AUIGrid.getCheckedRowItemsAll(auiGridMidRight);
			if (checkedItems.length == 0) {
				alert("체크된 부품이 없습니다.");
				return false;
			} else {
				for (var i = 0; i < checkedItems.length; ++i) {
					AUIGrid.removeRowByRowId(auiGridMidRight, checkedItems[i]._$uid);	
				}
			}
		}
		
		// 그리드1
		function createAUIGridTop1() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText : "메이커",
					dataField : "maker_name",
				},
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop1 = AUIGrid.create("#auiGridTop1", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop1, []);
		}
		
		// 그리드2
		function createAUIGridTop2() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "모델명",
					dataField : "machine_name",
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop2 = AUIGrid.create("#auiGridTop2", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop2, []);
		}
		
		// 그리드3
		function createAUIGridTop3() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "차대번호",
					dataField : "body_no"
				},
				{
					dataField : "machine_seq",
					visible : false
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop3 = AUIGrid.create("#auiGridTop3", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop3, []);
		}
	
		// 그리드4
		function createAUIGridTop4() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				editable : true
			};
			
			var columnLayout = [
				{
					headerText : "시작",
					dataField : "sale_st_dt",
					dataType : "date",   
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						  type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						  defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						  onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						  maxlength : 8,
						  showEditorBtn : false,
						  onlyNumeric : true, // 숫자만
						  validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							  return fnCheckDate(oldValue, newValue, rowItem);
						  }
					},
				},
				{
					headerText : "종료",
					dataField : "sale_ed_dt",
					dataType : "date",   
					style : "aui-center aui-editable",
					dataInputString : "yyyymmdd",
					formatString : "yyyy-mm-dd",
					editRenderer : {
						  type : "JQCalendarRenderer", // datepicker 달력 렌더러 사용
						  defaultFormat : "yyyymmdd", // 원래 데이터 날짜 포맷과 일치 시키세요. (기본값: "yyyy/mm/dd")
						  onlyCalendar : true, // 사용자 입력 불가, 즉 달력으로만 날짜입력 ( 기본값: true )
						  maxlength : 8,
						  showEditorBtn : false,
						  onlyNumeric : true, // 숫자만
						  validator : function(oldValue, newValue, rowItem) { // 에디팅 유효성 검사
							  return fnCheckDate(oldValue, newValue, rowItem);
						  }
					},
				},
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop4 = AUIGrid.create("#auiGridTop4", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop4, []);
		}
	
		// 그리드5
		function createAUIGridTop5() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "지역",
					dataField : "mem_name",
				},
				{
					dataField : "pro_mem_no",
					visible : false
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop5 = AUIGrid.create("#auiGridTop5", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop5, []);
		}
	
		// 그리드6
		function createAUIGridTop6() {
			var gridPros = {
				showRowNumColumn : true,
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "센터명",
					dataField : "center_org_name",
				},
				{
					dataField : "center_org_code",
					visible : false
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridTop6 = AUIGrid.create("#auiGridTop6", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridTop6, []);
		}
		
		// 부품판가 산출코드 그리드
		function createAUIGridMidLeft() {
			var gridPros = {
				showRowNumColumn : true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "산출코드",
					dataField : "part_output_price_cd",
				},
				{
					headerText : "내용",
					dataField : "part_output_price_name",
					style : "aui-left"
				},
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidLeft = AUIGrid.create("#auiGridMidLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidLeft, []);
		}
		
		// 제외부품 그리드
		function createAUIGridMidRight() {
			var gridPros = {
					showRowNumColumn : true,
					//체크박스 출력 여부
					showRowCheckColumn : true,
					//전체선택 체크박스 표시 여부
					showRowAllCheckBox : true,
			};
			
			var columnLayout = [
				{
					headerText : "부품번호",
					dataField : "part_no",
				},
				{
					headerText : "부품명",
					dataField : "part_name",
					style : "aui-left"
				},
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridMidRight = AUIGrid.create("#auiGridMidRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridMidRight, []);
		}
		
		// 대상고객 그리드
		function createAUIGridBom() {
			var gridPros = {
					showRowNumColumn : true,
			};
			
			var columnLayout = [
				{
					headerText : "메이커",
					dataField : "maker_name",
				},
				{
					dataField : "maker_cd",
					visible : false
				},
				{
					headerText : "모델",
					dataField : "machine_name",
				},
				{
					dataField : "machine_plant_seq",
					visible : false
				},
				{
					headerText : "판매일자",
					dataField : "sale_dt",
					style : "aui-center",
					dataType : "date",
					formatString : "yyyy-mm-dd",
				},
				{
					headerText : "차대번호",
					dataField : "body_no",
				},
				{
					headerText : "마케팅담당자",
					dataField : "sale_mem_name",
				},
				{
					headerText : "담당센터",
					dataField : "center_org_name",
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
				},
				{
					headerText : "핸드폰",
					dataField : "hp_no",
					labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
					     return $M.phoneFormat(value); 
					},
				},
				{
					dataField : "cust_no",
					visible : false
				},
				{
					dataField : "cust_machine_seq",
					visible : false
				}
			];
			
			// 실제로 #grid_wrap에 그리드 생성
			auiGridBom = AUIGrid.create("#auiGridBom", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridBom, []);
		}
		
		function fnDownloadExcel() {
			fnExportExcel(auiGridBom, "프로모션 대상고객", {});
		}
		
		function fnList() {
			$M.goNextPage("/serv/serv0302");
		}
    
	</script>
</head>
<body>
<form id="main_form" name="main_form">
<div class="layout-box">
<!-- contents 전체 영역 -->
		<div class="content-wrap">
			<div class="content-box">
<!-- 상세페이지 타이틀 -->
				<div class="main-title detail">
					<div class="detail-left">
						<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
						<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
					</div>
				</div>
<!-- /상세페이지 타이틀 -->
				<div class="contents">
<!-- 폼테이블1 -->					
					<div>
						<table class="table-border">
							<colgroup>
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="">
								<col width="100px">
								<col width="50%">
							</colgroup>
							<tbody>
								<tr>
									<th class="text-right essential-item">시행부서</th>
									<td colspan="3">
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="org_code" value="4000" id="org_code_sale" required="required" alt="시행부서">
											<label class="form-check-label" for="org_code_sale">마케팅</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="org_code" value="5000" id="org_code_service" checked="checked">
											<label class="form-check-label" for="org_code_service">서비스</label>
										</div>
										<div class="form-check form-check-inline">
											<input class="form-check-input" type="radio" name="org_code" value="6000" id="org_code_part">
											<label class="form-check-label" for="org_code_part">부품</label>
										</div>
									</td>
									<th class="text-right essential-item">제목</th>
									<td>
										<input type="text" class="form-control essential-bg" id="title" name="title" alt="제목" maxlength="50">
									</td>
								</tr>
								<tr>
									<th class="text-right essential-item">시행기간</th>
									<td colspan="3">
										<div class="form-row inline-pd widthfix">
											<div class="col width110px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate rb" id="start_dt" name="start_dt" dateformat="yyyy-MM-dd" alt="시행시작일">
												</div>
											</div>
											<div class="col-auto">~</div>
											<div class="col width120px">
												<div class="input-group">
													<input type="text" class="form-control border-right-0 calDate rb" id="end_dt" name="end_dt" dateformat="yyyy-MM-dd" alt="시행종료일">
												</div>
											</div>
										</div>
									</td>
									<th rowspan="2" class="text-right essential-item">내용</th>
									<td rowspan="2">
										<textarea class="form-control essential-bg" style="height: 100%;" maxlength="100" alt="내용" id="content" name="content"></textarea>
									</td>
								</tr>
								<tr>
									<th class="text-right">첨부이미지</th>
									<td colspan="3">
										<div class="table-attfile attach_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
											<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile('attach');">파일찾기</button>
											&nbsp;&nbsp;
											</div>
										</div>
									</td>	
								</tr>
								<tr>
									<th class="text-right">이벤트 목록 배너</th>
									<td colspan="3">
										<div class="table-attfile banner_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
												<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="bannerImageFileAddBtn" onclick="javascript:fnAddFile('banner');">파일찾기</button>
												&nbsp;&nbsp;
											</div>
										</div>
									</td>
									<th class="text-right">이벤트 상세이미지</th>
									<td>
										<div class="table-attfile detail_file_div" style="width:100%;">
											<div class="table-attfile" style="float:left">
												<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="detailImageFileAddBtn" onclick="javascript:fnAddFile('detail');">파일찾기</button>
												&nbsp;&nbsp;
											</div>
										</div>
									</td>
								</tr>
							</tbody>
						</table>
					</div>					
<!-- /폼테이블1 -->
<!-- 폼테이블2 -->
					<div class="title-wrap mt20">
						<div class="left">
							<h4>적용범위</h4>
							<div class="right radio-area">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="apply_target_ao" id="apply_target_a" value="A" alt="적용범위" required="required" checked="checked">
									<label class="form-check-label" for="apply_target_a">AND</label>
								</div>
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="radio" name="apply_target_ao" id="apply_target_o" value="O" alt="적용범위">
									<label class="form-check-label" for="apply_target_o">OR</label>
								</div>		
							</div>
						</div>						
					</div>
					<div class="row box-border mg0">
						<div class="col-2 box-gray">
<!-- 메이커 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="target_maker_yn_check" name="target_maker_yn_check" alt="메이커적용여부" value="Y">
									<input type="hidden" name="target_maker_yn">
									<label class="form-check-label" for="target_maker_yn_check">메이커</label>
								</div>
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goAddMaker()">추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemoveMaker()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop1" style="margin-top: 5px; height: 150px;"></div>
<!-- /메이커 -->	
						</div>
						<div class="col-2 box-gray">
<!-- 모델 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="target_mch_plant_yn_check" name="target_mch_plant_yn_check" alt="모델적용여부" value="Y">
									<input type="hidden" name="target_mch_plant_yn">
									<label class="form-check-label" for="target_mch_plant_yn_check">모델</label>
								</div>
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goAddModel()">추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemoveModel()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop2" style="margin-top: 5px; height: 150px;"></div>
<!-- /모델 -->	
						</div>
						<div class="col-2 box-gray">
<!-- 차대번호 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="target_mch_yn_check" name="target_mch_yn_check" alt="차대번호적용여부" value="Y">
									<input type="hidden" name="target_mch_yn">
									<label class="form-check-label" for="target_mch_yn_check">차대번호</label>
								</div>
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goAddBodyNo()">추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemoveBodyNo()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop3" style="margin-top: 5px; height: 150px;"></div>
<!-- /차대번호 -->	
						</div>
						<div class="col-2 box-gray">
<!-- 판매일자 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="target_sale_dt_yn_check" name="target_sale_dt_yn_check" alt="판매일자적용여부" value="Y">
									<input type="hidden" name="target_sale_dt_yn">
									<label class="form-check-label" for="target_sale_dt_yn_check">판매일자</label>
								</div>
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goAddSaleDt()">추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemoveSaleDt()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop4" style="margin-top: 5px; height: 150px;"></div>
<!-- /판매일자 -->	
						</div>
						<div class="col-2 box-gray">
<!-- 영업담당 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="target_sale_mem_yn_check" name="target_sale_mem_yn_check" value="Y" alt="마케팅담당자적용여부">
									<input type="hidden" name="target_sale_mem_yn">
									<label class="form-check-label" for="target_sale_mem_yn_check">마케팅담당</label>
								</div>
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goAddSaleMemNo()">추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemoveSaleMemNo()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop5" style="margin-top: 5px; height: 150px;"></div>
<!-- /영업담당 -->	
						</div>
						<div class="col-2 box-gray">
<!-- 담당센터 -->
							<div class="title-wrap mt5">
								<div class="form-check form-check-inline">
									<input class="form-check-input" type="checkbox" id="target_center_yn_check" name="target_center_yn_check" value="Y" alt="센터적용여부">
									<input type="hidden" name="target_center_yn">
									<label class="form-check-label" for="target_center_yn_check">담당센터</label>
								</div>
								<div class="right">
									<button type="button" class="btn btn-default" onclick="javascript:goAddCenter()">추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemoveCenter()">삭제</button>
								</div>
							</div>
							<div id="auiGridTop6" style="margin-top: 5px; height: 150px;"></div>
<!-- /담당센터 -->	
						</div>
					</div>
<!-- /폼테이블2 -->
					<div class="row mt10">
		                <div class="col" style="width: 45%;">
		                    <div class="title-wrap mt10">
		                        <div class="left">
		                            <h4>적용조건</h4>
		                            <div class="right radio-area">
		                                <div class="form-check form-check-inline">
		                                    <input class="form-check-input" type="radio" name="apply_condition_ao" id="apply_condition_a" value="A" alt="적용조건" checked="checked">
		                                    <label class="form-check-label" for="apply_condition_a">AND</label>
		                                </div>
		                                <div class="form-check form-check-inline">
		                                    <input class="form-check-input" type="radio" name="apply_condition_ao" id="apply_condition_o" value="O">
		                                    <label class="form-check-label" for="apply_condition_o">OR</label>
		                                </div>		
		                            </div>
		                        </div>						
		                    </div>
		                    <div class="condition-box">
		                        <div>
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_aio" id="condition_aio_a" value="A" checked="checked">
		                                <label class="form-check-label" for="condition_aio_a">전체</label>
		                            </div>
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_aio" id="condition_aio_i" value="I">
		                                <label class="form-check-label" for="condition_aio_i">입고</label>
		                            </div>
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_aio" id="condition_aio_o" value="O">
		                                <label class="form-check-label" for="condition_aio_o">출장</label>
		                            </div>
		                        </div>
		                        <div class="div-line">
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_ard" id="condition_ard_a" value="A" checked="checked">
		                                <label class="form-check-label" for="condition_ard_a">전체</label>
		                            </div>
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_ard" id="condition_ard_r" value="R">
		                                <label class="form-check-label" for="condition_ard_r">예약</label>
		                            </div>
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_ard" id="condition_ard_d" value="D">
		                                <label class="form-check-label" for="condition_ard_d">당일</label>
		                            </div>
		                        </div>
		                        <div class="div-line">
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_acs" id="condition_acs_a" value="A" checked="checked">
		                                <label class="form-check-label" for="condition_acs_a">전체</label>
		                            </div>
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_acs" id="condition_acs_c" value="C">
		                                <label class="form-check-label" for="condition_acs_c">CAP</label>
		                            </div>
		                            <div class="form-check form-check-inline">
		                                <input class="form-check-input" type="radio" name="condition_acs" id="condition_acs_s" value="S">
		                                <label class="form-check-label" for="condition_acs_s">초기/종료</label>
		                            </div>
		                        </div>                                    
		                    </div>                            
		                </div>
		                <div class="col" style="width: 20%;">
		                    <div class="title-wrap mt10">
		                        <div class="left">
		                            <h4>혜택구분</h4>
		                        </div>						
		                    </div>
		                    <div class="condition-box">
		                        <div class="checkbox-area">
		                            <div class="form-check form-check-inline" style="flex-basis: 54px;">
		                                <input class="form-check-input mr5" type="radio" name="benefit_type_md_check" id="benefit_type_md_m" checked="checked" value="M">
		                                <label class="form-check-label" for="benefit_type_md_m">금액</label>
		                            </div>						
		                            <input type="text" class="form-control text-right width100px mr3" id="benefit_amt" name="benefit_amt" format="decimal">
		                            <span class="pr15"></span>
		                            <div class="form-check form-check-inline ml15 div-line" style="width: 50px;">
		                                <input class="form-check-input" type="radio" name="benefit_type_md_check" id="benefit_type_md_d" value="D">
		                                <label class="form-check-label" for="benefit_type_md_d">할인</label>
		                            </div>				
		                            <input type="hidden" name="benefit_type_md" value="M">					
		                        </div>
		                    </div>
		                </div>
		                <div class="col" style="width: 35%;">
		                    <div class="title-wrap mt10">
		                        <div class="left">
		                            <h4>혜택할인</h4>
		                            <div class="right radio-area">
		                                <div class="form-check form-check-inline">
		                                    <input class="form-check-input" type="radio" name="apply_type_ao" id="apply_type_a" value="A" alt="혜택할인" required="required" checked="checked">
		                                    <label class="form-check-label" for="apply_type_a">AND</label>
		                                </div>
		                                <div class="form-check form-check-inline">
		                                    <input class="form-check-input" type="radio" name="apply_type_ao" id="apply_type_o" value="O">
		                                    <label class="form-check-label" for="apply_type_o">OR</label>
		                                </div>		
		                            </div>
		                        </div>						
		                    </div>
		                    <div class="condition-box">
		                        <div class="checkbox-area">
		                            <div class="form-check form-check-inline" style="flex-basis: 54px;">
		                                <input class="form-check-input" type="checkbox" id="type_wares_yn_check" name="type_wares_yn_check" value="Y" alt="공임적용여부">
		                                <input type="hidden" name="type_wares_yn">
		                                <label class="form-check-label" for="type_wares_yn_check">공임</label>
		                            </div>						
		                            <input type="text" class="form-control text-right width33px mr3" id="type_wares_dc_rate" name="type_wares_dc_rate" format="num" min="0" max="100" alt="공임할인율">
		                            <span class="pr15">%</span>
		                            <div class="form-check form-check-inline ml15 div-line" style="width: 64px;">
		                                <input class="form-check-input" type="checkbox" id="type_trip_yn_check" name="type_trip_yn_check" value="Y" alt="출장비적용여부">
		                                <input type="hidden" name="type_trip_yn">
		                                <label class="form-check-label" for="type_trip_yn_check">출장비</label>
		                            </div>		
		                            <input type="text" class="form-control text-right width33px mr3" id="type_trip_dc_rate" name="type_trip_dc_rate" format="num" min="0" max="100" alt="출장비할인율">
		                            <span class="pr15">%</span>		
		                            <div class="form-check form-check-inline ml15 div-line" style="width: 45px;">
		                                <input class="form-check-input" type="checkbox" id="type_part_yn_check" name="type_part_yn_check" value="Y" alt="부품적용여부">
		                                <input type="hidden" name="type_part_yn">
		                                <label class="form-check-label" for="type_part_yn_check">부품</label>
		                            </div>		
		                            <input type="text" class="form-control text-right width33px mr3" id="type_part_dc_rate" name="type_part_dc_rate" format="num" min="0" max="100" alt="부품할인율">
		                            <span class="pr10">%</span>						
		                        </div>							
		                    </div>
		                </div>
		            </div>
<!-- 폼테이블3 -->
					<div class="row mt10">
						<div class="col-6">
<!-- 부품판가 산출코드 -->							
							<div class="title-wrap mt10">
								<div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="part_output_price_yn_check" name="part_output_price_yn_check" value="Y" alt="부품판가 산출코드">
										<input type="hidden" name="part_output_price_yn">
										<label class="form-check-label" for="part_output_price_yn_check">부품판가 산출코드</label>
									</div>
								</div>
								<div class="right dpf" style="flex: 1; justify-content: flex-end;">
									<div class="mr3" style="flex-basis: 130px;">
										<select class="form-control" id="selectd_code_value" name="selectd_code_value">
											<option value="">- 선택 -</option>
											<c:forEach var="item" items="${codeMap['PART_OUTPUT_PRICE']}">
												<option value="${item.code_value}">${item.code_name}</option>
											</c:forEach>
										</select>								
									</div>
									<button type="button" class="btn btn-default mr3" onclick="javascript:fnAddPartOutput()"><i class="material-iconsadd text-default"></i>추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemovePartOutput();"><i class="material-iconsclose text-default"></i>삭제</button>
								</div>
							</div>						
							<div id="auiGridMidLeft" style="margin-top: 5px; height: 150px;"></div>
<!-- /부품판가 산출코드 -->									
						</div>
						<div class="col-6">
<!-- 제외부품 -->									
							<div class="title-wrap mt10">
								<div>
									<div class="form-check form-check-inline">
										<input class="form-check-input" type="checkbox" id="part_exclude_yn_check" name="part_exclude_yn_check" value="Y">
										<input type="hidden" name="part_exclude_yn">
										<label class="form-check-label" for="part_exclude_yn_check">제외부품</label>
									</div>
								</div>
								<div class="right">			
									<button type="button" class="btn btn-default" onclick="javascript:goAddPart()"><i class="material-iconsadd text-default"></i>추가</button>
									<button type="button" class="btn btn-default" onclick="javascript:fnRemovePart();"><i class="material-iconsclose text-default"></i>삭제</button>
								</div>
							</div>						
							<div id="auiGridMidRight" style="margin-top: 5px; height: 150px;"></div>
<!-- /제외부품 -->								
						</div>
					</div>
<!-- /폼테이블3 -->
<!-- 대상고객 -->
					<div class="title-wrap mt10">
						<h4>대상고객</h4>
						<div class="right">
							<span class="text-warning">※ 프로모션 대상의 경우 적용범위가 설정되어야 검색이 가능합니다.</span>
							<button type="button" class="btn btn-default" onclick="javascript:goSearch()"><i class="material-iconssearch text-default"></i>대상고객검색</button>
							<span><button type="button" id="_fnDownloadExcel" class="btn btn-default" onclick="javascript:fnDownloadExcel();"><i class="icon-btn-excel inline-btn"></i>엑셀다운로드</button></span>
						</div>
					</div>
					<div id="auiGridBom" style="margin-top: 5px; height: 200px;"></div>
<!-- /대상고객 -->
				<div class="btn-group mt10">
					<div class="left">
						총 <strong class="text-primary" id="total_cnt">0</strong>건
					</div>
					<div class="right">
						<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
					</div>	
				</div>						
			</div>	
		</div>
		<jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
<!-- /contents 전체 영역 -->	
</div>
</div>
    <input type="hidden" name="attach1_file_seq" value="0"/>
    <input type="hidden" name="banner1_file_seq" value="0"/>
    <input type="hidden" name="detail1_file_seq" value="0"/>
    <input type="hidden" name="detail2_file_seq" value="0"/>
    <input type="hidden" name="detail3_file_seq" value="0"/>
    <input type="hidden" name="detail4_file_seq" value="0"/>
    <input type="hidden" name="detail5_file_seq" value="0"/>
</form>
</body>
</html>